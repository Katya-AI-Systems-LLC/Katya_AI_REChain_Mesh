package websocket

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/rechain-network/katya-mesh-go/internal/mesh"
	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for demo
	},
}

// Server provides WebSocket server for real-time updates
type Server struct {
	broker    *mesh.Broker
	clients   map[*websocket.Conn]bool
	clientsMutex sync.RWMutex
	broadcast chan []byte
}

// NewServer creates a new WebSocket server
func NewServer(broker *mesh.Broker) *Server {
	return &Server{
		broker:    broker,
		clients:   make(map[*websocket.Conn]bool),
		broadcast: make(chan []byte),
	}
}

// HandleWebSocket handles WebSocket connections
func (s *Server) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}
	defer conn.Close()

	s.clientsMutex.Lock()
	s.clients[conn] = true
	s.clientsMutex.Unlock()

	log.Printf("WebSocket client connected: %s", r.RemoteAddr)

	// Send initial stats
	stats := s.broker.GetStats()
	if data, err := json.Marshal(map[string]any{
		"type": "stats",
		"data": stats,
	}); err == nil {
		conn.WriteMessage(websocket.TextMessage, data)
	}

	// Handle messages from client
	go s.handleClientMessages(conn)

	// Broadcast updates to client
	for {
		select {
		case message := <-s.broadcast:
			err := conn.WriteMessage(websocket.TextMessage, message)
			if err != nil {
				log.Printf("WebSocket write error: %v", err)
				s.clientsMutex.Lock()
				delete(s.clients, conn)
				s.clientsMutex.Unlock()
				return
			}
		}
	}
}

func (s *Server) handleClientMessages(conn *websocket.Conn) {
	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error: %v", err)
			}
			break
		}

		// Handle message (e.g., send mesh message)
		var msg struct {
			Type    string `json:"type"`
			To      string `json:"to"`
			Message string `json:"message"`
		}
		if err := json.Unmarshal(message, &msg); err == nil && msg.Type == "send_message" {
			meshMsg := protocol.NewMessage(msg.To, msg.Message, "normal")
			// Broadcast to all WebSocket clients
			data, _ := json.Marshal(map[string]any{
				"type": "message",
				"data": meshMsg,
			})
			s.Broadcast(data)
		}
	}
}

// Broadcast sends message to all connected clients
func (s *Server) Broadcast(message []byte) {
	s.clientsMutex.RLock()
	defer s.clientsMutex.RUnlock()

	for client := range s.clients {
		err := client.WriteMessage(websocket.TextMessage, message)
		if err != nil {
			log.Printf("WebSocket broadcast error: %v", err)
			delete(s.clients, client)
		}
	}
}

// BroadcastStats broadcasts stats update
func (s *Server) BroadcastStats(stats *mesh.Stats) {
	data, err := json.Marshal(map[string]any{
		"type": "stats",
		"data": stats,
	})
	if err == nil {
		s.Broadcast(data)
	}
}

// BroadcastMessage broadcasts mesh message
func (s *Server) BroadcastMessage(msg *protocol.Message) {
	data, err := json.Marshal(map[string]any{
		"type": "message",
		"data": msg,
	})
	if err == nil {
		s.Broadcast(data)
	}
}

// BroadcastPoll broadcasts poll update
func (s *Server) BroadcastPoll(poll *protocol.VotingPoll) {
	data, err := json.Marshal(map[string]any{
		"type": "poll",
		"data": poll,
	})
	if err == nil {
		s.Broadcast(data)
	}
}

