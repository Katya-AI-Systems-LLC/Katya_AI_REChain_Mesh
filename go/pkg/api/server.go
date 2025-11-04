package api

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/rechain-network/katya-mesh-go/internal/mesh"
	"github.com/rechain-network/katya-mesh-go/internal/storage"
	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

// Server provides REST API for mesh broker
type Server struct {
	broker  *mesh.Broker
	storage *storage.Storage
	port    int
	server  *http.Server
}

// NewServer creates a new API server
func NewServer(broker *mesh.Broker, port int) *Server {
	return &Server{
		broker:  broker,
		storage: broker.GetStorage(),
		port:    port,
	}
}

// Start starts the HTTP server
func (s *Server) Start() error {
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("/health", s.handleHealth)

	// Peers
	mux.HandleFunc("/api/v1/peers", s.handlePeers)

	// Messages
	mux.HandleFunc("/api/v1/messages/send", s.handleSendMessage)
	mux.HandleFunc("/api/v1/messages", s.handleListMessages)

	// Polls
	mux.HandleFunc("/api/v1/polls", s.handlePolls)
	mux.HandleFunc("/api/v1/polls/create", s.handleCreatePoll)
	mux.HandleFunc("/api/v1/polls/vote", s.handleVote)

	// Stats
	mux.HandleFunc("/api/v1/stats", s.handleStats)

	// AI Analysis
	mux.HandleFunc("/api/v1/polls/analyze", s.handleAnalyzePoll)

	s.server = &http.Server{
		Addr:         fmt.Sprintf(":%d", s.port),
		Handler:      mux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	log.Printf("Starting API server on port %d", s.port)
	return s.server.ListenAndServe()
}

// Stop stops the HTTP server
func (s *Server) Stop() error {
	if s.server != nil {
		return s.server.Close()
	}
	return nil
}

func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"status": "ok",
		"time":   time.Now().Unix(),
	})
}

func (s *Server) handlePeers(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	peers := s.broker.GetPeers()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"peers": peers,
		"count": len(peers),
	})
}

func (s *Server) handleSendMessage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		To      string `json:"to"`
		Message string `json:"message"`
		Priority string `json:"priority,omitempty"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	if req.Message == "" {
		http.Error(w, "Message is required", http.StatusBadRequest)
		return
	}

	if req.To == "" {
		req.To = "broadcast"
	}

	if req.Priority == "" {
		req.Priority = "normal"
	}

	msg := protocol.NewMessage(req.To, req.Message, req.Priority)
	
	// Save to storage
	if s.storage != nil {
		s.storage.SaveMessage(msg)
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"success": true,
		"message": msg,
	})
}

func (s *Server) handleListMessages(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	messages := []protocol.Message{}
	if s.storage != nil {
		messages = s.storage.GetMessages()
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"messages": messages,
		"count":    len(messages),
	})
}

func (s *Server) handlePolls(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	polls := []*protocol.VotingPoll{}
	if s.storage != nil {
		polls = s.storage.GetAllPolls()
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"polls": polls,
		"count": len(polls),
	})
}

func (s *Server) handleCreatePoll(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Title       string `json:"title"`
		Description string `json:"description"`
		Options     string `json:"options"`
		CreatorID   string `json:"creatorId,omitempty"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	if req.Title == "" || req.Options == "" {
		http.Error(w, "Title and options are required", http.StatusBadRequest)
		return
	}

	if req.CreatorID == "" {
		req.CreatorID = "api-user"
	}

	poll := protocol.NewPoll(req.Title, req.Description, req.Options, req.CreatorID)
	
	// Save to storage
	if s.storage != nil {
		s.storage.SavePoll(poll)
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"success": true,
		"poll":    poll,
	})
}

func (s *Server) handleVote(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		PollID  string `json:"pollId"`
		Option  string `json:"option"`
		UserID  string `json:"userId,omitempty"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	if req.PollID == "" || req.Option == "" {
		http.Error(w, "Poll ID and option are required", http.StatusBadRequest)
		return
	}

	if req.UserID == "" {
		req.UserID = "api-user"
	}

	vote := protocol.NewVote(req.PollID, req.UserID, req.Option)
	
	// Save vote and update poll
	if s.storage != nil {
		s.storage.SaveVote(vote)
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"success": true,
		"vote":    vote,
	})
}

func (s *Server) handleStats(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	stats := s.broker.GetStats()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}

func (s *Server) handleAnalyzePoll(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		PollID string `json:"pollId"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	if req.PollID == "" {
		http.Error(w, "Poll ID is required", http.StatusBadRequest)
		return
	}

	// Get poll from storage
	var poll *protocol.VotingPoll
	var exists bool
	if s.storage != nil {
		poll, exists = s.storage.GetPoll(req.PollID)
	}

	if !exists || poll == nil {
		http.Error(w, "Poll not found", http.StatusNotFound)
		return
	}

	// Analyze poll
	leader, leaderVotes := poll.GetLeader()
	total := poll.GetTotalVotes()
	percentages := poll.GetPercentages()
	
	analysis := fmt.Sprintf(`📊 AI Analysis of poll "%s":

🎯 Leader: %s (%d votes, %.1f%%)
📈 Total Votes: %d
⚡ Status: %s

📊 Breakdown:`, poll.Title, leader, leaderVotes, 
		percentages[leader], total, 
		map[bool]string{true: "Active", false: "Completed"}[poll.IsActive])

	for option, pct := range percentages {
		count := poll.Votes[option]
		analysis += fmt.Sprintf("\n  %s: %d votes (%.1f%%)", option, count, pct)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"pollId":   req.PollID,
		"analysis": analysis,
		"leader":   leader,
		"total":    total,
		"percentages": percentages,
	})
}

