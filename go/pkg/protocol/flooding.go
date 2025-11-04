package protocol

import (
	"context"
	"sync"
	"time"

	"go.uber.org/zap"
)

// FloodingProtocol implements a simple flooding protocol for mesh networks
type FloodingProtocol struct {
	nodeID       string
	peers        map[string]*Peer
	messageCache map[string]time.Time // Message ID -> timestamp
	cacheMutex   sync.RWMutex
	ttl          time.Duration
	maxHops      int
	logger       *zap.Logger
}

// NewFloodingProtocol creates a new flooding protocol instance
func NewFloodingProtocol(nodeID string, ttl time.Duration, maxHops int, logger *zap.Logger) *FloodingProtocol {
	return &FloodingProtocol{
		nodeID:       nodeID,
		peers:        make(map[string]*Peer),
		messageCache: make(map[string]time.Time),
		ttl:          ttl,
		maxHops:      maxHops,
		logger:       logger,
	}
}

// AddPeer adds a peer to the flooding protocol
func (fp *FloodingProtocol) AddPeer(peer *Peer) {
	fp.peers[peer.ID] = peer
	fp.logger.Info("Added peer to flooding protocol", zap.String("peerID", peer.ID))
}

// RemovePeer removes a peer from the flooding protocol
func (fp *FloodingProtocol) RemovePeer(peerID string) {
	delete(fp.peers, peerID)
	fp.logger.Info("Removed peer from flooding protocol", zap.String("peerID", peerID))
}

// Broadcast broadcasts a message using flooding
func (fp *FloodingProtocol) Broadcast(ctx context.Context, message *Message) error {
	return fp.floodMessage(ctx, message, 0, make(map[string]bool))
}

// floodMessage recursively floods a message to all peers
func (fp *FloodingProtocol) floodMessage(ctx context.Context, message *Message, hops int, visited map[string]bool) error {
	// Check if we've exceeded max hops
	if hops >= fp.maxHops {
		return nil
	}

	// Check if message is too old
	fp.cacheMutex.RLock()
	timestamp, exists := fp.messageCache[message.ID]
	fp.cacheMutex.RUnlock()

	if exists && time.Since(timestamp) > fp.ttl {
		// Clean up old cache entry
		fp.cacheMutex.Lock()
		delete(fp.messageCache, message.ID)
		fp.cacheMutex.Unlock()
	} else if exists {
		// Message already seen recently
		return nil
	}

	// Mark message as seen
	fp.cacheMutex.Lock()
	fp.messageCache[message.ID] = time.Now()
	fp.cacheMutex.Unlock()

	// Mark current node as visited
	visited[fp.nodeID] = true

	// Send to all unvisited peers
	for peerID, peer := range fp.peers {
		if visited[peerID] {
			continue
		}

		// Create a copy of the message with updated hop count
		floodedMessage := &Message{
			ID:        message.ID,
			Type:      message.Type,
			From:      message.From,
			To:        message.To,
			Payload:   message.Payload,
			Timestamp: message.Timestamp,
			Hops:      hops + 1,
			TTL:       message.TTL - 1,
		}

		// Send message to peer
		if err := peer.SendMessage(ctx, floodedMessage); err != nil {
			fp.logger.Error("Failed to send flooded message to peer",
				zap.String("peerID", peerID),
				zap.Error(err))
			continue
		}

		fp.logger.Debug("Flooded message to peer",
			zap.String("peerID", peerID),
			zap.String("messageID", message.ID),
			zap.Int("hops", hops+1))
	}

	return nil
}

// HandleIncomingMessage handles incoming flooded messages
func (fp *FloodingProtocol) HandleIncomingMessage(ctx context.Context, message *Message) error {
	// Check if message is too old
	if message.TTL <= 0 {
		return nil
	}

	// Continue flooding
	return fp.floodMessage(ctx, message, message.Hops, make(map[string]bool))
}

// GetStats returns protocol statistics
func (fp *FloodingProtocol) GetStats() map[string]interface{} {
	fp.cacheMutex.RLock()
	cacheSize := len(fp.messageCache)
	fp.cacheMutex.RUnlock()

	return map[string]interface{}{
		"peers":      len(fp.peers),
		"cache_size": cacheSize,
		"ttl":        fp.ttl.String(),
		"max_hops":   fp.maxHops,
	}
}

// Cleanup removes expired cache entries
func (fp *FloodingProtocol) Cleanup() {
	fp.cacheMutex.Lock()
	defer fp.cacheMutex.Unlock()

	now := time.Now()
	for messageID, timestamp := range fp.messageCache {
		if now.Sub(timestamp) > fp.ttl {
			delete(fp.messageCache, messageID)
		}
	}
}
