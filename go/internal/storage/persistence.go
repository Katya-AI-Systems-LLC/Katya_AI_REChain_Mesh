package storage

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

// Storage manages persistent storage for mesh state
type Storage struct {
	dataDir    string
	messages   []protocol.Message
	polls      map[string]*protocol.VotingPoll
	votes      map[string][]*protocol.Vote
	mutex      sync.RWMutex
}

// NewStorage creates a new storage instance
func NewStorage(dataDir string) (*Storage, error) {
	if dataDir == "" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			return nil, fmt.Errorf("failed to get home dir: %w", err)
		}
		dataDir = filepath.Join(homeDir, ".katya-mesh")
	}

	if err := os.MkdirAll(dataDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create data dir: %w", err)
	}

	s := &Storage{
		dataDir:  dataDir,
		messages: make([]protocol.Message, 0),
		polls:    make(map[string]*protocol.VotingPoll),
		votes:    make(map[string][]*protocol.Vote),
	}

	// Load existing data
	if err := s.Load(); err != nil {
		return nil, fmt.Errorf("failed to load data: %w", err)
	}

	return s, nil
}

// SaveMessage saves a message
func (s *Storage) SaveMessage(msg *protocol.Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = append(s.messages, *msg)
	return s.persistMessages()
}

// GetMessages returns all messages
func (s *Storage) GetMessages() []protocol.Message {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	messages := make([]protocol.Message, len(s.messages))
	copy(messages, s.messages)
	return messages
}

// SavePoll saves a poll
func (s *Storage) SavePoll(poll *protocol.VotingPoll) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.polls[poll.ID] = poll
	return s.persistPolls()
}

// GetPoll retrieves a poll by ID
func (s *Storage) GetPoll(pollID string) (*protocol.VotingPoll, bool) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	poll, exists := s.polls[pollID]
	return poll, exists
}

// GetAllPolls returns all polls
func (s *Storage) GetAllPolls() []*protocol.VotingPoll {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	polls := make([]*protocol.VotingPoll, 0, len(s.polls))
	for _, poll := range s.polls {
		polls = append(polls, poll)
	}
	return polls
}

// SaveVote saves a vote
func (s *Storage) SaveVote(vote *protocol.Vote) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	if s.votes[vote.PollID] == nil {
		s.votes[vote.PollID] = make([]*protocol.Vote, 0)
	}
	s.votes[vote.PollID] = append(s.votes[vote.PollID], vote)

	// Update poll vote count
	if poll, exists := s.polls[vote.PollID]; exists {
		poll.AddVote(vote.Option)
		return s.persistPolls()
	}

	return s.persistVotes()
}

// GetVotes returns votes for a poll
func (s *Storage) GetVotes(pollID string) []*protocol.Vote {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	votes := s.votes[pollID]
	if votes == nil {
		return []*protocol.Vote{}
	}

	result := make([]*protocol.Vote, len(votes))
	copy(result, votes)
	return result
}

// Load loads data from disk
func (s *Storage) Load() error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	// Load messages
	messagesFile := filepath.Join(s.dataDir, "messages.json")
	if data, err := os.ReadFile(messagesFile); err == nil {
		json.Unmarshal(data, &s.messages)
	}

	// Load polls
	pollsFile := filepath.Join(s.dataDir, "polls.json")
	if data, err := os.ReadFile(pollsFile); err == nil {
		var pollsMap map[string]*protocol.VotingPoll
		if err := json.Unmarshal(data, &pollsMap); err == nil {
			s.polls = pollsMap
		}
	}

	// Load votes
	votesFile := filepath.Join(s.dataDir, "votes.json")
	if data, err := os.ReadFile(votesFile); err == nil {
		var votesMap map[string][]*protocol.Vote
		if err := json.Unmarshal(data, &votesMap); err == nil {
			s.votes = votesMap
		}
	}

	return nil
}

// persistMessages saves messages to disk
func (s *Storage) persistMessages() error {
	file := filepath.Join(s.dataDir, "messages.json")
	data, err := json.MarshalIndent(s.messages, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(file, data, 0644)
}

// persistPolls saves polls to disk
func (s *Storage) persistPolls() error {
	file := filepath.Join(s.dataDir, "polls.json")
	data, err := json.MarshalIndent(s.polls, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(file, data, 0644)
}

// persistVotes saves votes to disk
func (s *Storage) persistVotes() error {
	file := filepath.Join(s.dataDir, "votes.json")
	data, err := json.MarshalIndent(s.votes, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(file, data, 0644)
}

// Clear clears all stored data
func (s *Storage) Clear() error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = make([]protocol.Message, 0)
	s.polls = make(map[string]*protocol.VotingPoll)
	s.votes = make(map[string][]*protocol.Vote)

	// Clear files
	os.Remove(filepath.Join(s.dataDir, "messages.json"))
	os.Remove(filepath.Join(s.dataDir, "polls.json"))
	os.Remove(filepath.Join(s.dataDir, "votes.json"))

	return nil
}

