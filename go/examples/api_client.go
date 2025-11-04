package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Example API client for mesh broker
func main() {
	baseURL := "http://localhost:8080"

	fmt.Println("Katya Mesh Go - API Client Example")

	// Health check
	fmt.Println("\n1. Health Check:")
	health, _ := http.Get(baseURL + "/health")
	body, _ := io.ReadAll(health.Body)
	fmt.Println(string(body))

	// Get peers
	fmt.Println("\n2. Get Peers:")
	peersResp, _ := http.Get(baseURL + "/api/v1/peers")
	peersBody, _ := io.ReadAll(peersResp.Body)
	fmt.Println(string(peersBody))

	// Send message
	fmt.Println("\n3. Send Message:")
	msgData := map[string]any{
		"to":      "broadcast",
		"message": "Hello from API client!",
		"priority": "normal",
	}
	msgJSON, _ := json.Marshal(msgData)
	resp, _ := http.Post(baseURL+"/api/v1/messages/send", "application/json", bytes.NewBuffer(msgJSON))
	respBody, _ := io.ReadAll(resp.Body)
	fmt.Println(string(respBody))

	// Create poll
	fmt.Println("\n4. Create Poll:")
	pollData := map[string]any{
		"title":       "Where to meet?",
		"description": "Choose a location",
		"options":     "Cafe,Park,Office",
		"creatorId":   "api-client",
	}
	pollJSON, _ := json.Marshal(pollData)
	resp, _ = http.Post(baseURL+"/api/v1/polls/create", "application/json", bytes.NewBuffer(pollJSON))
	respBody, _ = io.ReadAll(resp.Body)
	fmt.Println(string(respBody))

	// Get stats
	fmt.Println("\n5. Get Stats:")
	statsResp, _ := http.Get(baseURL + "/api/v1/stats")
	statsBody, _ := io.ReadAll(statsResp.Body)
	fmt.Println(string(statsBody))

	// Wait a bit
	time.Sleep(2 * time.Second)

	fmt.Println("\nExample complete!")
}

