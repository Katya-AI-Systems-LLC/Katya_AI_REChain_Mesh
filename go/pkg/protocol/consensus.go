package protocol

import (
	"context"
	"crypto/sha256"
	"fmt"
	"math"
	"sort"
	"sync"
	"time"

	"go.uber.org/zap"
)

// ConsensusProtocol implements a simple consensus protocol for mesh networks
type ConsensusProtocol struct {
	nodeID       string
	peers        map[string]*Peer
	votes        map[string]*VoteRound
	voteMutex    sync.RWMutex
	quorumSize   int
	timeout      time.Duration
	logger       *zap.Logger
}

// VoteRound represents a voting round
type VoteRound struct {
	ID          string
	Proposal    interface{}
	Votes       map[string]Vote
	StartTime   time.Time
	EndTime     *time.Time
	Consensus   *ConsensusResult
}

// Vote represents a single vote
type Vote struct {
	NodeID    string
	Value     interface{}
	Timestamp time.Time
	Signature []byte
}

// ConsensusResult represents the result of a consensus round
type ConsensusResult struct {
	Value      interface{}
	VoteCount  int
	TotalVotes int
	Achieved   bool
}

// NewConsensusProtocol creates a new consensus protocol instance
func NewConsensusProtocol(nodeID string, quorumSize int, timeout time.Duration, logger *zap.Logger) *ConsensusProtocol {
	return &ConsensusProtocol{
		nodeID:     nodeID,
		peers:      make(map[string]*Peer),
		votes:      make(map[string]*VoteRound),
		quorumSize: quorumSize,
		timeout:    timeout,
		logger:     logger,
	}
}

// AddPeer adds a peer to the consensus protocol
func (cp *ConsensusProtocol) AddPeer(peer *Peer) {
	cp.peers[peer.ID] = peer
	cp.logger.Info("Added peer to consensus protocol", zap.String("peerID", peer.ID))
}

// RemovePeer removes a peer from the consensus protocol
func (cp *ConsensusProtocol) RemovePeer(peerID string) {
	delete(cp.peers, peerID)
	cp.logger.Info("Removed peer from consensus protocol", zap.String("peerID", peerID))
}

// Propose starts a new consensus round with a proposal
func (cp *ConsensusProtocol) Propose(ctx context.Context, proposalID string, proposal interface{}) error {
	round := &VoteRound{
		ID:        proposalID,
		Proposal:  proposal,
		Votes:     make(map[string]Vote),
		StartTime: time.Now(),
	}

	cp.voteMutex.Lock()
	cp.votes[proposalID] = round
	cp.voteMutex.Unlock()

	// Vote for our own proposal
	if err := cp.Vote(ctx, proposalID, proposal); err != nil {
		return fmt.Errorf("failed to vote for own proposal: %w", err)
	}

	// Broadcast proposal to peers
	return cp.broadcastProposal(ctx, round)
}

// Vote casts a vote in a consensus round
func (cp *ConsensusProtocol) Vote(ctx context.Context, proposalID string, value interface{}) error {
	cp.voteMutex.Lock()
	round, exists := cp.votes[proposalID]
	cp.voteMutex.Unlock()

	if !exists {
		return fmt.Errorf("proposal %s not found", proposalID)
	}

	vote := Vote{
		NodeID:    cp.nodeID,
		Value:     value,
		Timestamp: time.Now(),
		// TODO: Add signature
	}

	cp.voteMutex.Lock()
	round.Votes[cp.nodeID] = vote
	cp.voteMutex.Unlock()

	// Broadcast vote to peers
	return cp.broadcastVote(ctx, proposalID, vote)
}

// broadcastProposal broadcasts a proposal to all peers
func (cp *ConsensusProtocol) broadcastProposal(ctx context.Context, round *VoteRound) error {
	for peerID, peer := range cp.peers {
		message := &Message{
			ID:        fmt.Sprintf("proposal_%s_%s", round.ID, cp.nodeID),
			Type:      MessageTypeConsensusProposal,
			From:      cp.nodeID,
			To:        peerID,
			Payload:   round,
			Timestamp: time.Now(),
			Hops:      1,
			TTL:       10,
		}

		if err := peer.SendMessage(ctx, message); err != nil {
			cp.logger.Error("Failed to broadcast proposal to peer",
				zap.String("peerID", peerID),
				zap.String("proposalID", round.ID),
				zap.Error(err))
		}
	}

	return nil
}

// broadcastVote broadcasts a vote to all peers
func (cp *ConsensusProtocol) broadcastVote(ctx context.Context, proposalID string, vote Vote) error {
	for peerID, peer := range cp.peers {
		message := &Message{
			ID:        fmt.Sprintf("vote_%s_%s", proposalID, cp.nodeID),
			Type:      MessageTypeConsensusVote,
			From:      cp.nodeID,
			To:        peerID,
			Payload:   map[string]interface{}{"proposalID": proposalID, "vote": vote},
			Timestamp: time.Now(),
			Hops:      1,
			TTL:       10,
		}

		if err := peer.SendMessage(ctx, message); err != nil {
			cp.logger.Error("Failed to broadcast vote to peer",
				zap.String("peerID", peerID),
				zap.String("proposalID", proposalID),
				zap.Error(err))
		}
	}

	return nil
}

// HandleIncomingMessage handles incoming consensus messages
func (cp *ConsensusProtocol) HandleIncomingMessage(message *Message) {
	switch message.Type {
	case MessageTypeConsensusProposal:
		cp.handleProposal(message)
	case MessageTypeConsensusVote:
		cp.handleVote(message)
	}
}

// handleProposal handles an incoming proposal
func (cp *ConsensusProtocol) handleProposal(message *Message) {
	round, ok := message.Payload.(*VoteRound)
	if !ok {
		cp.logger.Error("Invalid proposal payload")
		return
	}

	cp.voteMutex.Lock()
	existing, exists := cp.votes[round.ID]
	if !exists {
		cp.votes[round.ID] = round
		cp.logger.Info("Received new proposal", zap.String("proposalID", round.ID))
	} else if existing.StartTime.After(round.StartTime) {
		// Update with newer proposal
		cp.votes[round.ID] = round
	}
	cp.voteMutex.Unlock()

	// TODO: Decide whether to vote for this proposal
}

// handleVote handles an incoming vote
func (cp *ConsensusProtocol) handleVote(message *Message) {
	payload, ok := message.Payload.(map[string]interface{})
	if !ok {
		cp.logger.Error("Invalid vote payload")
		return
	}

	proposalID, ok := payload["proposalID"].(string)
	if !ok {
		cp.logger.Error("Missing proposalID in vote")
		return
	}

	vote, ok := payload["vote"].(Vote)
	if !ok {
		cp.logger.Error("Invalid vote data")
		return
	}

	cp.voteMutex.Lock()
	round, exists := cp.votes[proposalID]
	if !exists {
		cp.logger.Warn("Received vote for unknown proposal", zap.String("proposalID", proposalID))
		cp.voteMutex.Unlock()
		return
	}

	round.Votes[vote.NodeID] = vote
	cp.voteMutex.Unlock()

	cp.logger.Debug("Received vote",
		zap.String("proposalID", proposalID),
		zap.String("voterID", vote.NodeID))

	// Check for consensus
	cp.checkConsensus(proposalID)
}

// checkConsensus checks if consensus has been reached
func (cp *ConsensusProtocol) checkConsensus(proposalID string) {
	cp.voteMutex.Lock()
	round := cp.votes[proposalID]
	cp.voteMutex.Unlock()

	if round == nil || round.Consensus != nil {
		return
	}

	totalPeers := len(cp.peers) + 1 // Including ourselves
	voteCounts := make(map[interface{}]int)

	for _, vote := range round.Votes {
		// Create hash of vote value for comparison
		hash := sha256.Sum256([]byte(fmt.Sprintf("%v", vote.Value)))
		voteCounts[string(hash[:])]++
	}

	// Find majority vote
	var majorityValue interface{}
	maxVotes := 0

	for value, count := range voteCounts {
		if count > maxVotes {
			maxVotes = count
			majorityValue = value
		}
	}

	// Check if we have quorum
	quorumReached := maxVotes >= int(math.Ceil(float64(totalPeers)*0.67)) // 2/3 majority

	if quorumReached {
		round.Consensus = &ConsensusResult{
			Value:      majorityValue,
			VoteCount:  maxVotes,
			TotalVotes: len(round.Votes),
			Achieved:   true,
		}

		now := time.Now()
		round.EndTime = &now

		cp.logger.Info("Consensus achieved",
			zap.String("proposalID", proposalID),
			zap.Int("votes", maxVotes),
			zap.Int("total", totalPeers))
	}
}

// GetConsensusResult returns the result of a consensus round
func (cp *ConsensusProtocol) GetConsensusResult(proposalID string) *ConsensusResult {
	cp.voteMutex.RLock()
	round, exists := cp.votes[proposalID]
	cp.voteMutex.RUnlock()

	if !exists || round.Consensus == nil {
		return nil
	}

	return round.Consensus
}

// GetStats returns protocol statistics
func (cp *ConsensusProtocol) GetStats() map[string]interface{} {
	cp.voteMutex.RLock()
	activeRounds := len(cp.votes)
	cp.voteMutex.RUnlock()

	return map[string]interface{}{
		"peers":         len(cp.peers),
		"active_rounds": activeRounds,
		"quorum_size":   cp.quorumSize,
		"timeout":       cp.timeout.String(),
	}
}

// Cleanup removes old completed consensus rounds
func (cp *ConsensusProtocol) Cleanup(maxAge time.Duration) {
	cp.voteMutex.Lock()
	defer cp.voteMutex.Unlock()

	now := time.Now()
	for id, round := range cp.votes {
		if round.EndTime != nil && now.Sub(*round.EndTime) > maxAge {
			delete(cp.votes, id)
		}
	}
}
