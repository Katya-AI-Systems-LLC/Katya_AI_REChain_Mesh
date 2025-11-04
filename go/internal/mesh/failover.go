package mesh

import (
	"sync"
	"time"

	"go.uber.org/zap"
)

// FailoverManager handles peer failover and recovery
type FailoverManager struct {
	peers         map[string]*Peer
	failedPeers   map[string]*FailedPeerInfo
	mutex         sync.RWMutex
	retryInterval time.Duration
	maxRetries    int
	logger        *zap.Logger
}

// FailedPeerInfo tracks information about failed peers
type FailedPeerInfo struct {
	Peer         *Peer
	FailureTime  time.Time
	RetryCount   int
	LastRetry    time.Time
}

// NewFailoverManager creates a new failover manager
func NewFailoverManager(logger *zap.Logger) *FailoverManager {
	return &FailoverManager{
		peers:         make(map[string]*Peer),
		failedPeers:   make(map[string]*FailedPeerInfo),
		retryInterval: 30 * time.Second,
		maxRetries:    5,
		logger:        logger,
	}
}

// AddPeer adds a peer to failover management
func (fm *FailoverManager) AddPeer(peer *Peer) {
	fm.mutex.Lock()
	defer fm.mutex.Unlock()

	fm.peers[peer.ID] = peer
	fm.logger.Debug("Added peer to failover manager", zap.String("peerID", peer.ID))
}

// RemovePeer removes a peer from failover management
func (fm *FailoverManager) RemovePeer(peerID string) {
	fm.mutex.Lock()
	defer fm.mutex.Unlock()

	delete(fm.peers, peerID)
	delete(fm.failedPeers, peerID)
	fm.logger.Debug("Removed peer from failover manager", zap.String("peerID", peerID))
}

// HandlePeerFailure handles a peer failure
func (fm *FailoverManager) HandlePeerFailure(peer *Peer) {
	fm.mutex.Lock()
	defer fm.mutex.Unlock()

	info, exists := fm.failedPeers[peer.ID]
	if !exists {
		info = &FailedPeerInfo{
			Peer:        peer,
			FailureTime: time.Now(),
			RetryCount:  0,
		}
		fm.failedPeers[peer.ID] = info
	}

	info.RetryCount++
	info.LastRetry = time.Now()

	fm.logger.Warn("Peer failure handled",
		zap.String("peerID", peer.ID),
		zap.Int("retryCount", info.RetryCount),
		zap.Int("maxRetries", fm.maxRetries))

	// Check if max retries exceeded
	if info.RetryCount >= fm.maxRetries {
		fm.logger.Error("Peer exceeded max retries, marking as permanently failed",
			zap.String("peerID", peer.ID))
		return
	}

	// Schedule retry
	go fm.scheduleRetry(peer.ID)
}

// scheduleRetry schedules a retry for a failed peer
func (fm *FailoverManager) scheduleRetry(peerID string) {
	time.Sleep(fm.retryInterval)

	fm.mutex.Lock()
	info, exists := fm.failedPeers[peerID]
	if !exists {
		fm.mutex.Unlock()
		return
	}

	peer := info.Peer
	fm.mutex.Unlock()

	// Attempt to reconnect
	if err := peer.Reconnect(); err != nil {
		fm.logger.Warn("Peer reconnection failed",
			zap.String("peerID", peerID),
			zap.Error(err))

		// Handle failure again
		fm.HandlePeerFailure(peer)
	} else {
		fm.logger.Info("Peer successfully reconnected",
			zap.String("peerID", peerID))

		// Remove from failed peers
		fm.mutex.Lock()
		delete(fm.failedPeers, peerID)
		fm.mutex.Unlock()

		// Mark as healthy
		peer.SetHealthy(true)
	}
}

// GetFailedPeers returns information about failed peers
func (fm *FailoverManager) GetFailedPeers() map[string]*FailedPeerInfo {
	fm.mutex.RLock()
	defer fm.mutex.RUnlock()

	failedPeers := make(map[string]*FailedPeerInfo)
	for id, info := range fm.failedPeers {
		failedPeers[id] = &FailedPeerInfo{
			Peer:        info.Peer,
			FailureTime: info.FailureTime,
			RetryCount:  info.RetryCount,
			LastRetry:   info.LastRetry,
		}
	}

	return failedPeers
}

// IsPeerFailed checks if a peer is currently failed
func (fm *FailoverManager) IsPeerFailed(peerID string) bool {
	fm.mutex.RLock()
	defer fm.mutex.RUnlock()

	_, exists := fm.failedPeers[peerID]
	return exists
}

// GetRetryStats returns retry statistics
func (fm *FailoverManager) GetRetryStats() map[string]interface{} {
	fm.mutex.RLock()
	defer fm.mutex.RUnlock()

	totalFailed := len(fm.failedPeers)
	totalRetries := 0

	for _, info := range fm.failedPeers {
		totalRetries += info.RetryCount
	}

	return map[string]interface{}{
		"failed_peers":   totalFailed,
		"total_retries":  totalRetries,
		"retry_interval": fm.retryInterval.String(),
		"max_retries":    fm.maxRetries,
	}
}

// Cleanup removes old failed peer entries that have exceeded max retries
func (fm *FailoverManager) Cleanup() {
	fm.mutex.Lock()
	defer fm.mutex.Unlock()

	for peerID, info := range fm.failedPeers {
		if info.RetryCount >= fm.maxRetries {
			// Check if it's been too long since last retry
			if time.Since(info.LastRetry) > fm.retryInterval*2 {
				delete(fm.failedPeers, peerID)
				fm.logger.Info("Cleaned up permanently failed peer",
					zap.String("peerID", peerID))
			}
		}
	}
}

// GetStats returns failover manager statistics
func (fm *FailoverManager) GetStats() map[string]interface{} {
	fm.mutex.RLock()
	defer fm.mutex.RUnlock()

	stats := fm.GetRetryStats()
	stats["managed_peers"] = len(fm.peers)

	return stats
}
