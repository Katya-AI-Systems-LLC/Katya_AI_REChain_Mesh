package mesh

import (
	"math/rand"
	"sync"
	"time"

	"go.uber.org/zap"
)

// LoadBalancer implements load balancing for mesh peers
type LoadBalancer struct {
	peers     map[string]*Peer
	peerList  []*Peer
	mutex     sync.RWMutex
	strategy  LoadBalanceStrategy
	logger    *zap.Logger
}

// LoadBalanceStrategy defines load balancing strategies
type LoadBalanceStrategy int

const (
	RoundRobin LoadBalanceStrategy = iota
	Random
	LeastConnections
	WeightedRandom
)

// NewLoadBalancer creates a new load balancer
func NewLoadBalancer(logger *zap.Logger) *LoadBalancer {
	return &LoadBalancer{
		peers:    make(map[string]*Peer),
		peerList: make([]*Peer, 0),
		strategy: RoundRobin,
		logger:   logger,
	}
}

// AddPeer adds a peer to the load balancer
func (lb *LoadBalancer) AddPeer(peer *Peer) {
	lb.mutex.Lock()
	defer lb.mutex.Unlock()

	if _, exists := lb.peers[peer.ID]; !exists {
		lb.peers[peer.ID] = peer
		lb.peerList = append(lb.peerList, peer)
		lb.logger.Debug("Added peer to load balancer", zap.String("peerID", peer.ID))
	}
}

// RemovePeer removes a peer from the load balancer
func (lb *LoadBalancer) RemovePeer(peerID string) {
	lb.mutex.Lock()
	defer lb.mutex.Unlock()

	if peer, exists := lb.peers[peerID]; exists {
		delete(lb.peers, peerID)

		// Remove from peer list
		for i, p := range lb.peerList {
			if p.ID == peerID {
				lb.peerList = append(lb.peerList[:i], lb.peerList[i+1:]...)
				break
			}
		}

		lb.logger.Debug("Removed peer from load balancer", zap.String("peerID", peerID))
	}
}

// SelectPeer selects a peer based on the load balancing strategy
func (lb *LoadBalancer) SelectPeer(targetID string) *Peer {
	lb.mutex.RLock()
	defer lb.mutex.RUnlock()

	if len(lb.peerList) == 0 {
		return nil
	}

	// If target is specified and exists, return it
	if targetID != "" && targetID != "broadcast" {
		if peer, exists := lb.peers[targetID]; exists && peer.IsHealthy() {
			return peer
		}
	}

	// Filter healthy peers
	healthyPeers := make([]*Peer, 0)
	for _, peer := range lb.peerList {
		if peer.IsHealthy() {
			healthyPeers = append(healthyPeers, peer)
		}
	}

	if len(healthyPeers) == 0 {
		return nil
	}

	// Apply load balancing strategy
	switch lb.strategy {
	case RoundRobin:
		return lb.selectRoundRobin(healthyPeers)
	case Random:
		return lb.selectRandom(healthyPeers)
	case LeastConnections:
		return lb.selectLeastConnections(healthyPeers)
	case WeightedRandom:
		return lb.selectWeightedRandom(healthyPeers)
	default:
		return lb.selectRoundRobin(healthyPeers)
	}
}

// selectRoundRobin implements round-robin load balancing
func (lb *LoadBalancer) selectRoundRobin(peers []*Peer) *Peer {
	// Simple round-robin using current time as seed
	index := int(time.Now().UnixNano()) % len(peers)
	return peers[index]
}

// selectRandom implements random load balancing
func (lb *LoadBalancer) selectRandom(peers []*Peer) *Peer {
	return peers[rand.Intn(len(peers))]
}

// selectLeastConnections implements least connections load balancing
func (lb *LoadBalancer) selectLeastConnections(peers []*Peer) *Peer {
	minPeer := peers[0]
	minConnections := minPeer.GetConnectionCount()

	for _, peer := range peers[1:] {
		if connections := peer.GetConnectionCount(); connections < minConnections {
			minPeer = peer
			minConnections = connections
		}
	}

	return minPeer
}

// selectWeightedRandom implements weighted random load balancing
func (lb *LoadBalancer) selectWeightedRandom(peers []*Peer) *Peer {
	totalWeight := 0
	for _, peer := range peers {
		totalWeight += peer.GetWeight()
	}

	if totalWeight == 0 {
		return lb.selectRandom(peers)
	}

	randomValue := rand.Intn(totalWeight)
	currentWeight := 0

	for _, peer := range peers {
		currentWeight += peer.GetWeight()
		if randomValue < currentWeight {
			return peer
		}
	}

	// Fallback to last peer
	return peers[len(peers)-1]
}

// SetStrategy sets the load balancing strategy
func (lb *LoadBalancer) SetStrategy(strategy LoadBalanceStrategy) {
	lb.mutex.Lock()
	defer lb.mutex.Unlock()
	lb.strategy = strategy
	lb.logger.Info("Changed load balancing strategy", zap.Int("strategy", int(strategy)))
}

// GetStats returns load balancer statistics
func (lb *LoadBalancer) GetStats() map[string]interface{} {
	lb.mutex.RLock()
	defer lb.mutex.RUnlock()

	healthyCount := 0
	totalConnections := 0

	for _, peer := range lb.peerList {
		if peer.IsHealthy() {
			healthyCount++
		}
		totalConnections += peer.GetConnectionCount()
	}

	return map[string]interface{}{
		"total_peers":        len(lb.peerList),
		"healthy_peers":      healthyCount,
		"total_connections":  totalConnections,
		"strategy":           lb.strategy.String(),
	}
}

// String returns string representation of LoadBalanceStrategy
func (lbs LoadBalanceStrategy) String() string {
	switch lbs {
	case RoundRobin:
		return "round_robin"
	case Random:
		return "random"
	case LeastConnections:
		return "least_connections"
	case WeightedRandom:
		return "weighted_random"
	default:
		return "unknown"
	}
}
