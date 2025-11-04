package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/rechain-network/katya-mesh-go/internal/mesh"
	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]
	args := os.Args[2:]

	switch command {
	case "start":
		handleStart(args)
	case "stop":
		handleStop()
	case "peers":
		handlePeers()
	case "send":
		handleSend(args)
	case "poll":
		handlePoll(args)
	case "stats":
		handleStats()
	case "help", "-h", "--help":
		printUsage()
	default:
		fmt.Printf("Unknown command: %s\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println(`Katya Mesh CLI - Offline mesh network management

Usage:
  meshctl <command> [flags]

Commands:
  start           Start mesh network
  stop            Stop mesh network
  peers           List discovered peers
  send            Send message to peer
  poll            Manage voting polls
  stats           Show mesh network statistics
  help            Show this help message

Examples:
  meshctl start --adapter emulated
  meshctl peers
  meshctl send --to peer-123 --message "Hello!"
  meshctl poll create --title "Where?" --options "A,B,C"
  meshctl poll vote --poll-id abc123 --option "A"
  meshctl stats`)
}

func handleStart(args []string) {
	fs := flag.NewFlagSet("start", flag.ExitOnError)
	adapter := fs.String("adapter", "emulated", "Mesh adapter (emulated, wifi_emulated, android_ble)")
	fs.Parse(args)

	fmt.Printf("Starting mesh network with adapter: %s\n", *adapter)
	
	broker := mesh.NewBroker(*adapter)
	if err := broker.Start(); err != nil {
		log.Fatalf("Failed to start mesh: %v", err)
	}
	
	fmt.Println("Mesh network started. Press Ctrl+C to stop.")
	
	// Keep running
	select {}
}

func handleStop() {
	fmt.Println("Stopping mesh network...")
	// TODO: Implement stop logic
	fmt.Println("Mesh network stopped")
}

func handlePeers() {
	fmt.Println("Discovering peers...")
	// TODO: Connect to broker and list peers
	fmt.Println("No peers found (broker not running)")
}

func handleSend(args []string) {
	fs := flag.NewFlagSet("send", flag.ExitOnError)
	to := fs.String("to", "broadcast", "Recipient peer ID")
	message := fs.String("message", "", "Message content")
	priority := fs.String("priority", "normal", "Message priority (low, normal, high)")
	fs.Parse(args)

	if *message == "" {
		log.Fatal("Message is required")
	}

	fmt.Printf("Sending message to %s: %s\n", *to, *message)
	
	msg := protocol.NewMessage(*to, *message, *priority)
	data, _ := json.MarshalIndent(msg, "", "  ")
	fmt.Println(string(data))
	
	// TODO: Send via broker
	fmt.Println("Message sent (broker not connected)")
}

func handlePoll(args []string) {
	if len(args) < 1 {
		fmt.Println("poll: missing subcommand")
		fmt.Println("Usage: meshctl poll <create|vote|list|analyze> [flags]")
		os.Exit(1)
	}

	subcommand := args[0]
	subargs := args[1:]

	switch subcommand {
	case "create":
		handlePollCreate(subargs)
	case "vote":
		handlePollVote(subargs)
	case "list":
		handlePollList()
	case "analyze":
		handlePollAnalyze(subargs)
	default:
		fmt.Printf("Unknown poll command: %s\n", subcommand)
		os.Exit(1)
	}
}

func handlePollCreate(args []string) {
	fs := flag.NewFlagSet("poll create", flag.ExitOnError)
	title := fs.String("title", "", "Poll title")
	description := fs.String("description", "", "Poll description")
	options := fs.String("options", "", "Comma-separated options")
	creatorId := fs.String("creator", "cli-user", "Creator ID")
	fs.Parse(args)

	if *title == "" || *options == "" {
		log.Fatal("Title and options are required")
	}

	poll := protocol.NewPoll(*title, *description, *options, *creatorId)
	data, _ := json.MarshalIndent(poll, "", "  ")
	fmt.Println("Created poll:")
	fmt.Println(string(data))
}

func handlePollVote(args []string) {
	fs := flag.NewFlagSet("poll vote", flag.ExitOnError)
	pollId := fs.String("poll-id", "", "Poll ID")
	option := fs.String("option", "", "Vote option")
	userId := fs.String("user", "cli-user", "User ID")
	fs.Parse(args)

	if *pollId == "" || *option == "" {
		log.Fatal("Poll ID and option are required")
	}

	vote := protocol.NewVote(*pollId, *userId, *option)
	data, _ := json.MarshalIndent(vote, "", "  ")
	fmt.Println("Casted vote:")
	fmt.Println(string(data))
}

func handlePollList() {
	fmt.Println("Listing polls...")
	// TODO: Connect to broker and list polls
	fmt.Println("No polls found (broker not running)")
}

func handlePollAnalyze(args []string) {
	fs := flag.NewFlagSet("poll analyze", flag.ExitOnError)
	pollId := fs.String("poll-id", "", "Poll ID")
	fs.Parse(args)

	if *pollId == "" {
		log.Fatal("Poll ID is required")
	}

	fmt.Printf("Analyzing poll %s...\n", *pollId)
	// TODO: Get poll from broker and analyze
	fmt.Println("AI Analysis: (poll not found)")
}

func handleStats() {
	fmt.Println("Mesh Network Statistics:")
	fmt.Println("  Peers: 0")
	fmt.Println("  Messages in queue: 0")
	fmt.Println("  Success rate: 0%")
	fmt.Println("  Adapter: (not started)")
	// TODO: Connect to broker and get stats
}

