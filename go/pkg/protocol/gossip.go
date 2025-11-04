package protocol

import (
	"context"
	"math/rand"
	"sync"
	"time"

	"go.uber.org/zap"
)

// GossipProtocol implements a gossip protocol for mesh networks
type GossipProtocol struct {
	nodeID       string
	peers        map[string]*Peer
	messageCache map[string]*GossipMessage
	cacheMutex   sync.RWMutex
	fanout       int           // Number of peers to gossip to
	interval     time.Duration // Gossip interval
	maxRounds    int           // Maximum gossip rounds
	logger       *zap.Logger
	stopChan     chan struct{}
}

// GossipMessage represents a gossiped message with metadata
type GossipMessage struct {
	ID        string
	Round     int
	Timestamp time.Time
	Data      *Message
}

// NewGossipProtocol creates a new gossip protocol instance
func NewGossipProtocol(nodeID string, fanout int, interval time.Duration, maxRounds int, logger *zap.Logger) *GossipProtocol {
	return &GossipProtocol{
		nodeID:       nodeID,
		peers:        make(map[string]*Peer),
		messageCache: make(map[string]*GossipMessage),
		fanout:       fanout,
		interval:     interval,
		maxRounds:    maxRounds,
		logger:       logger,
		stopChan:     make(chan struct{}),
	}
}

// Start starts the gossip protocol
func (gp *GossipProtocol) Start() {
	go gp.gossipLoop()
	gp.logger.Info("Started gossip protocol", zap.String("nodeID", gp.nodeID))
}

// Stop stops the gossip protocol
func (gp *GossipProtocol) Stop() {
	close(gp.stopChan)
	gp.logger.Info("Stopped gossip protocol", zap.String("nodeID", gp.nodeID))
}

// gossipLoop runs the periodic gossip dissemination
func (gp *GossipProtocol) gossipLoop() {
	ticker := time.NewTicker(gp.interval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			gp.performGossip()
		case <-gp.stopChan:
			return
		}
	}
}

// performGossip performs one round of gossip
func (gp *GossipProtocol) performGossip() {
	gp.cacheMutex.RLock()
	messages := make([]*GossipMessage, 0, len(gp.messageCache))
	for _, msg := range gp.messageCache {
		if msg.Round < gp.maxRounds {
			messages = append(messages, msg)
		}
	}
	gp.cacheMutex.RUnlock()

	if len(messages) == 0 {
		return
	}

	// Select random peers for gossip
	peerIDs := gp.selectRandomPeers(gp.fanout)
	if len(peerIDs) == 0 {
		return
	}

	// Gossip each message
	for _, gossipMsg := range messages {
		gp.gossipMessage(gossipMsg, peerIDs)
	}
}

// gossipMessage gossips a single message to selected peers
func (gp *GossipProtocol) gossipMessage(gossipMsg *GossipMessage, peerIDs []string) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Update round
	updatedMsg := &GossipMessage{
		ID:        gossipMsg.ID,
		Round:     gossipMsg.Round + 1,
		Timestamp: gossipMsg.Timestamp,
		Data:      gossipMsg.Data,
	}

	// Send to selected peers
	for _, peerID := range peerIDs {
		peer, exists := gp.peers[peerID]
		if !exists {
			continue
		}

		// Create gossip payload
		gossipPayload := &Message{
			ID:        gossipMsg.ID + "_gossip_r" + string(rune(updatedMsg.Round)),
			Type:      MessageTypeGossip,
			From:      gp.nodeID,
			To:        peerID,
			Payload:   updatedMsg,
			Timestamp: time.Now(),
			Hops:      1,
			TTL:       10,
		}

		if err := peer.SendMessage(ctx, gossipPayload); err != nil {
			gp.logger.Error("Failed to gossip message to peer",
				zap.String("peerID", peerID),
				zap.String("messageID", gossipMsg.ID),
				zap.Error(err))
			continue
		}

		gp.logger.Debug("Gossiped message to peer",
			zap.String("peerID", peerID),
			zap.String("messageID", gossipMsg.ID),
			zap.Int("round", updatedMsg.Round))
	}

	// Update cache
	gp.cacheMutex.Lock()
	gp.messageCache[gossipMsg.ID] = updatedMsg
	gp.cacheMutex.Unlock()
}

// selectRandomPeers selects random peers for gossip
func (gp *GossipProtocol) selectRandomPeers(count int) []string {
	gp.cacheMutex.RLock()
	defer gp.cacheMutex.RUnlock()

	if len(gp.peers) == 0 {
		return nil
	}

	if count >= len(gp.peers) {
		peerIDs := make([]string, 0, len(gp.peers))
		for peerID := range gp.peers {
			peerIDs = append(peerIDs, peerID)
		}
		return peerIDs
	}

	peerIDs := make([]string, 0, len(gp.peers))
	for peerID := range gp.peers {
		peerIDs = append(peerIDs, peerID)
	}

	// Fisher-Yates shuffle
	for i := len(peerIDs) - 1; i > 0; i-- {
		j := rand.Intn(i + 1)
		peerIDs[i], peerIDs[j] = peerIDs[j], peerIDs[i]
	}

	return peerIDs[:count]
}

// AddPeer adds a peer to the gossip protocol
func (gp *GossipProtocol) AddPeer(peer *Peer) {
	gp.peers[peer.ID] = peer
	gp.logger.Info("Added peer to gossip protocol", zap.String("peerID", peer.ID))
}

// RemovePeer removes a peer from the gossip protocol
func (gp *GossipProtocol) RemovePeer(peerID string) {
	delete(gp.peers, peerID)
	gp.logger.Info("Removed peer from gossip protocol", zap.String("peerID", peerID))
}

// Broadcast starts gossip dissemination of a message
func (gp *GossipProtocol) Broadcast(message *Message) {
	gossipMsg := &GossipMessage{
		ID:        message.ID,
		Round:     0,
		Timestamp: time.Now(),
		Data:      message,
	}

	gp.cacheMutex.Lock()
	gp.messageCache[message.ID] = gossipMsg
	gp.cacheMutex.Unlock()

	gp.logger.Info("Started gossip broadcast", zap.String("messageID", message.ID))
}

// HandleIncomingMessage handles incoming gossiped messages
func (gp *GossipProtocol) HandleIncomingMessage(message *Message) {
	if message.Type != MessageTypeGossip {
		return
	}

	// Extract gossip message
	gossipMsg, ok := message.Payload.(*GossipMessage)
	if !ok {
		gp.logger.Error("Invalid gossip message payload")
		return
	}

	// Check if we've seen this message before
	gp.cacheMutex.RLock()
	existing, exists := gp.messageCache[gossipMsg.ID]
	gp.cacheMutex.RUnlock()

	if exists && existing.Round >= gossipMsg.Round {
		return // Already have newer or equal round
	}

	// Store/update message
	gp.cacheMutex.Lock()
	gp.messageCache[gossipMsg.ID] = gossipMsg
	gp.cacheMutex.Unlock()

	gp.logger.Debug("Received gossiped message",
		zap.String("messageID", gossipMsg.ID),
		zap.Int("round", gossipMsg.Round))
}

// GetStats returns protocol statistics
func (gp *GossipProtocol) GetStats() map[string]interface{} {
	gp.cacheMutex.RLock()
	cacheSize := len(gp.messageCache)
	gp.cacheMutex.RUnlock()

	return map[string]interface{}{
		"peers":       len(gp.peers),
		"cache_size":  cacheSize,
		"fanout":      gp.fanout,
		"interval":    gp.interval.String(),
		"max_rounds":  gp.maxRounds,
	}
}
