package protocol

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// VotingPoll represents a voting poll
type VotingPoll struct {
	ID          string            `json:"id"`
	Title       string            `json:"title"`
	Description string            `json:"description"`
	Options     []string          `json:"options"`
	Votes       map[string]int    `json:"votes"`
	CreatorID   string            `json:"creatorId"`
	CreatedAt   time.Time         `json:"createdAt"`
	IsActive    bool              `json:"isActive"`
	Metadata    map[string]any    `json:"metadata,omitempty"`
}

// Vote represents a cast vote
type Vote struct {
	ID        string    `json:"id"`
	PollID    string    `json:"pollId"`
	UserID    string    `json:"userId"`
	Option    string    `json:"option"`
	Timestamp time.Time `json:"timestamp"`
	Signature string    `json:"signature,omitempty"`
	PublicKey string    `json:"publicKey,omitempty"`
}

// NewPoll creates a new voting poll
func NewPoll(title, description, optionsStr, creatorID string) *VotingPoll {
	options := splitOptions(optionsStr)
	votes := make(map[string]int)
	for _, opt := range options {
		votes[opt] = 0
	}

	return &VotingPoll{
		ID:          uuid.New().String(),
		Title:       title,
		Description: description,
		Options:     options,
		Votes:       votes,
		CreatorID:   creatorID,
		CreatedAt:   time.Now(),
		IsActive:    true,
		Metadata:    make(map[string]any),
	}
}

// NewVote creates a new vote
func NewVote(pollID, userID, option string) *Vote {
	return &Vote{
		ID:        uuid.New().String(),
		PollID:    pollID,
		UserID:    userID,
		Option:    option,
		Timestamp: time.Now(),
	}
}

// ToJSON serializes poll to JSON
func (p *VotingPoll) ToJSON() ([]byte, error) {
	return json.Marshal(p)
}

// ToJSON serializes vote to JSON
func (v *Vote) ToJSON() ([]byte, error) {
	return json.Marshal(v)
}

// GetTotalVotes returns total number of votes
func (p *VotingPoll) GetTotalVotes() int {
	total := 0
	for _, count := range p.Votes {
		total += count
	}
	return total
}

// GetLeader returns the option with most votes
func (p *VotingPoll) GetLeader() (string, int) {
	leader := ""
	maxVotes := -1
	for option, count := range p.Votes {
		if count > maxVotes {
			maxVotes = count
			leader = option
		}
	}
	return leader, maxVotes
}

// GetPercentages calculates vote percentages
func (p *VotingPoll) GetPercentages() map[string]float64 {
	percentages := make(map[string]float64)
	total := p.GetTotalVotes()
	if total == 0 {
		for option := range p.Votes {
			percentages[option] = 0.0
		}
		return percentages
	}

	for option, count := range p.Votes {
		percentages[option] = float64(count) / float64(total) * 100.0
	}
	return percentages
}

// AddVote adds a vote to the poll
func (p *VotingPoll) AddVote(option string) {
	if _, exists := p.Votes[option]; exists {
		p.Votes[option]++
	}
}

// FinalizeByMajority marks poll as inactive with majority result
func (p *VotingPoll) FinalizeByMajority() string {
	leader, _ := p.GetLeader()
	p.IsActive = false
	return leader
}

func splitOptions(optionsStr string) []string {
	// Simple comma-split, can be enhanced
	result := []string{}
	last := 0
	for i, char := range optionsStr {
		if char == ',' {
			if i > last {
				opt := optionsStr[last:i]
				if len(opt) > 0 {
					result = append(result, opt)
				}
			}
			last = i + 1
		}
	}
	if last < len(optionsStr) {
		opt := optionsStr[last:]
		if len(opt) > 0 {
			result = append(result, opt)
		}
	}
	return result
}

