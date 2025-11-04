package main

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/rechain-network/katya-mesh-go/internal/mesh"
	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

func main() {
	fmt.Println("Katya Mesh Go - Simple Chat Example")

	// Start mesh broker
	broker := mesh.NewBroker("emulated")
	if err := broker.Start(); err != nil {
		log.Fatalf("Failed to start broker: %v", err)
	}
	defer broker.Stop()

	// Wait for peer discovery
	fmt.Println("Discovering peers...")
	time.Sleep(2 * time.Second)

	// List peers
	peers := broker.GetPeers()
	fmt.Printf("Discovered %d peers:\n", len(peers))
	for _, peer := range peers {
		fmt.Printf("  - %s (%s) RSSI: %d\n", peer.Name, peer.ID, peer.RSSI)
	}

	// Create and send a message
	if len(peers) > 0 {
		target := peers[0].ID
		msg := protocol.NewMessage(target, "Hello from Go!", "normal")
		data, _ := json.MarshalIndent(msg, "", "  ")
		fmt.Println("\nSending message:")
		fmt.Println(string(data))
	} else {
		// Broadcast if no peers
		msg := protocol.NewMessage("broadcast", "Hello mesh!", "normal")
		data, _ := json.MarshalIndent(msg, "", "  ")
		fmt.Println("\nBroadcasting message:")
		fmt.Println(string(data))
	}

	// Get stats
	stats := broker.GetStats()
	fmt.Printf("\nMesh Stats:\n")
	fmt.Printf("  Total Peers: %d\n", stats.TotalPeers)
	fmt.Printf("  Connected: %d\n", stats.ConnectedPeers)
	fmt.Printf("  Messages in Queue: %d\n", stats.MessagesInQueue)
	fmt.Printf("  Success Rate: %.2f%%\n", stats.SuccessRate)

	// Keep running
	fmt.Println("\nBroker running. Press Ctrl+C to stop.")
	select {}
}

