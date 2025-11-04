package protocol

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// MessagePriority represents message priority levels
type MessagePriority string

const (
	PriorityLow    MessagePriority = "low"
	PriorityNormal MessagePriority = "normal"
	PriorityHigh   MessagePriority = "high"
)

// Message represents a mesh message
type Message struct {
	ID        string          `json:"id"`
	FromID    string          `json:"fromId"`
	ToID      string          `json:"toId"`
	Content   string          `json:"message"`
	Timestamp time.Time       `json:"timestamp"`
	TTL       int             `json:"ttl"`
	Path      []string        `json:"path"`
	Priority  MessagePriority `json:"priority"`
	Type      string          `json:"type,omitempty"`
	Metadata  map[string]any  `json:"metadata,omitempty"`
}

// NewMessage creates a new mesh message
func NewMessage(toID, content, priority string) *Message {
	id := uuid.New().String()
	prio := MessagePriority(priority)
	if prio != PriorityLow && prio != PriorityHigh {
		prio = PriorityNormal
	}

	return &Message{
		ID:        id,
		FromID:    "cli",
		ToID:      toID,
		Content:   content,
		Timestamp: time.Now(),
		TTL:       10,
		Path:      []string{"cli"},
		Priority:  prio,
		Type:      "chat",
		Metadata:  make(map[string]any),
	}
}

// ToJSON serializes message to JSON
func (m *Message) ToJSON() ([]byte, error) {
	return json.Marshal(m)
}

// FromJSON deserializes message from JSON
func FromJSON(data []byte) (*Message, error) {
	var msg Message
	if err := json.Unmarshal(data, &msg); err != nil {
		return nil, err
	}
	return &msg, nil
}

// IsExpired checks if message TTL has expired
func (m *Message) IsExpired() bool {
	return m.TTL <= 0
}

// DecrementTTL decreases message TTL
func (m *Message) DecrementTTL() {
	m.TTL--
}

