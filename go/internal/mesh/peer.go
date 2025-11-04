package mesh

import (
	"sync"
	"time"
)

// PeerDiscovery interface for peer discovery mechanisms
type PeerDiscovery interface {
	Start() error
	Stop() error
	Discover() ([]*Peer, error)
}

// PeerManager manages peer lifecycle
type PeerManager struct {
	peers map[string]*Peer
	mutex sync.RWMutex
}

// NewPeerManager creates a new peer manager
func NewPeerManager() *PeerManager {
	return &PeerManager{
		peers: make(map[string]*Peer),
	}
}

// AddPeer adds or updates a peer
func (pm *PeerManager) AddPeer(peer *Peer) {
	pm.mutex.Lock()
	defer pm.mutex.Unlock()
	peer.LastSeen = time.Now()
	pm.peers[peer.ID] = peer
}

// RemovePeer removes a peer
func (pm *PeerManager) RemovePeer(peerID string) {
	pm.mutex.Lock()
	defer pm.mutex.Unlock()
	delete(pm.peers, peerID)
}

// GetPeer retrieves a peer by ID
func (pm *PeerManager) GetPeer(peerID string) (*Peer, bool) {
	pm.mutex.RLock()
	defer pm.mutex.RUnlock()
	peer, exists := pm.peers[peerID]
	return peer, exists
}

// IsConnected checks if peer is currently connected
func (p *Peer) IsConnected() bool {
	return time.Since(p.LastSeen) < 10*time.Second
}

// IsStrongSignal checks if peer has strong signal
func (p *Peer) IsStrongSignal() bool {
	return p.RSSI > -70
}

