package mesh

import (
	"context"
	"fmt"
	"sync"
	"time"

	"go.uber.org/zap"

	"github.com/rechain-network/katya-mesh-go/internal/crypto"
	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

// Broker represents the mesh network broker with load balancing and failover
type Broker struct {
	nodeID       string
	peers        map[string]*Peer
	peerMutex    sync.RWMutex
	protocols    map[string]protocol.Protocol
	protocolMutex sync.RWMutex
	loadBalancer *LoadBalancer
	failover     *FailoverManager
	encryption   *crypto.AESGCM
	logger       *zap.Logger
	stopChan     chan struct{}
}

// NewBroker creates a new mesh broker
func NewBroker(nodeID string, logger *zap.Logger) *Broker {
	encryption, _ := crypto.NewAESGCM([]byte("default-key-32-chars-long!!!")) // TODO: Use proper key management

	return &Broker{
		nodeID:       nodeID,
		peers:        make(map[string]*Peer),
		protocols:    make(map[string]protocol.Protocol),
		loadBalancer: NewLoadBalancer(logger),
		failover:     NewFailoverManager(logger),
		encryption:   encryption,
		logger:       logger,
		stopChan:     make(chan struct{}),
	}
}

// Start starts the broker
func (b *Broker) Start() {
	b.logger.Info("Starting mesh broker", zap.String("nodeID", b.nodeID))
	go b.healthCheckLoop()
}

// Stop stops the broker
func (b *Broker) Stop() {
	close(b.stopChan)
	b.logger.Info("Stopped mesh broker", zap.String("nodeID", b.nodeID))
}

// healthCheckLoop performs periodic health checks on peers
func (b *Broker) healthCheckLoop() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			b.performHealthChecks()
		case <-b.stopChan:
			return
		}
	}
}

// performHealthChecks checks the health of all peers
func (b *Broker) performHealthChecks() {
	b.peerMutex.RLock()
	peers := make([]*Peer, 0, len(b.peers))
	for _, peer := range b.peers {
		peers = append(peers, peer)
	}
	b.peerMutex.RUnlock()

	for _, peer := range peers {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)

		if err := peer.HealthCheck(ctx); err != nil {
			b.logger.Warn("Peer health check failed",
				zap.String("peerID", peer.ID),
				zap.Error(err))

			// Mark peer as unhealthy
			peer.SetHealthy(false)
			b.failover.HandlePeerFailure(peer)
		} else {
			peer.SetHealthy(true)
		}

		cancel()
	}
}

// AddPeer adds a peer to the broker
func (b *Broker) AddPeer(peer *Peer) {
	b.peerMutex.Lock()
	b.peers[peer.ID] = peer
	b.peerMutex.Unlock()

	b.loadBalancer.AddPeer(peer)
	b.failover.AddPeer(peer)

	// Add peer to all protocols
	b.protocolMutex.RLock()
	for _, protocol := range b.protocols {
		protocol.AddPeer(peer)
	}
	b.protocolMutex.RUnlock()

	b.logger.Info("Added peer to broker", zap.String("peerID", peer.ID))
}

// RemovePeer removes a peer from the broker
func (b *Broker) RemovePeer(peerID string) {
	b.peerMutex.Lock()
	peer, exists := b.peers[peerID]
	delete(b.peers, peerID)
	b.peerMutex.Unlock()

	if exists {
		b.loadBalancer.RemovePeer(peerID)
		b.failover.RemovePeer(peerID)

		// Remove peer from all protocols
		b.protocolMutex.RLock()
		for _, protocol := range b.protocols {
			protocol.RemovePeer(peerID)
		}
		b.protocolMutex.RUnlock()

		b.logger.Info("Removed peer from broker", zap.String("peerID", peerID))
	}
}

// AddProtocol adds a protocol to the broker
func (b *Broker) AddProtocol(name string, protocol protocol.Protocol) {
	b.protocolMutex.Lock()
	b.protocols[name] = protocol
	b.protocolMutex.Unlock()

	// Add all existing peers to the protocol
	b.peerMutex.RLock()
	for _, peer := range b.peers {
		protocol.AddPeer(peer)
	}
	b.peerMutex.RUnlock()

	b.logger.Info("Added protocol to broker", zap.String("protocol", name))
}

// SendMessage sends a message using load balancing
func (b *Broker) SendMessage(ctx context.Context, message *protocol.Message) error {
	// Encrypt message if needed
	if message.Type != protocol.MessageTypeHealth {
		encryptedPayload, err := b.encryption.Encrypt(message.Payload.([]byte))
		if err != nil {
			return fmt.Errorf("failed to encrypt message: %w", err)
		}
		message.Payload = encryptedPayload
	}

	// Use load balancer to select peer
	peer := b.loadBalancer.SelectPeer(message.To)
	if peer == nil {
		return fmt.Errorf("no available peer for destination: %s", message.To)
	}

	// Send message
	return peer.SendMessage(ctx, message)
}

// BroadcastMessage broadcasts a message to all peers
func (b *Broker) BroadcastMessage(ctx context.Context, message *protocol.Message) error {
	b.peerMutex.RLock()
	peers := make([]*Peer, 0, len(b.peers))
	for _, peer := range b.peers {
		peers = append(peers, peer)
	}
	b.peerMutex.RUnlock()

	// Send to all peers
	for _, peer := range peers {
		if err := peer.SendMessage(ctx, message); err != nil {
			b.logger.Error("Failed to broadcast message to peer",
				zap.String("peerID", peer.ID),
				zap.Error(err))
		}
	}

	return nil
}

// GetPeers returns all peers
func (b *Broker) GetPeers() ([]*Peer, error) {
	b.peerMutex.RLock()
	defer b.peerMutex.RUnlock()

	peers := make([]*Peer, 0, len(b.peers))
	for _, peer := range b.peers {
		peers = append(peers, peer)
	}

	return peers, nil
}

// GetStats returns broker statistics
func (b *Broker) GetStats() (map[string]interface{}, error) {
	b.peerMutex.RLock()
	peerCount := len(b.peers)
	b.peerMutex.RUnlock()

	b.protocolMutex.RLock()
	protocolCount := len(b.protocols)
	b.protocolMutex.RUnlock()

	stats := map[string]interface{}{
		"node_id":        b.nodeID,
		"peers":          peerCount,
		"protocols":      protocolCount,
		"load_balancer":  b.loadBalancer.GetStats(),
		"failover":       b.failover.GetStats(),
	}

	// Add protocol stats
	b.protocolMutex.RLock()
	for name, protocol := range b.protocols {
		stats["protocol_"+name] = protocol.GetStats()
	}
	b.protocolMutex.RUnlock()

	return stats, nil
}

// HandleMessage handles incoming messages
func (b *Broker) HandleMessage(message *protocol.Message) error {
	// Decrypt message if needed
	if message.Type != protocol.MessageTypeHealth {
		if encryptedPayload, ok := message.Payload.([]byte); ok {
			decryptedPayload, err := b.encryption.Decrypt(encryptedPayload)
			if err != nil {
				return fmt.Errorf("failed to decrypt message: %w", err)
			}
			message.Payload = decryptedPayload
		}
	}

	// Route to appropriate protocol
	b.protocolMutex.RLock()
	for _, protocol := range b.protocols {
		if err := protocol.HandleIncomingMessage(message); err != nil {
			b.logger.Error("Protocol failed to handle message",
				zap.String("protocol", fmt.Sprintf("%T", protocol)),
				zap.Error(err))
		}
	}
	b.protocolMutex.RUnlock()

	return nil
}
