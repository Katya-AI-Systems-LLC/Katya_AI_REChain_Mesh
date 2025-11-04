package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

func main() {
	fmt.Println("Katya Mesh Go - Simple Poll Example")

	// Create a poll
	poll := protocol.NewPoll(
		"Where should we meet?",
		"Choose a location for the afterparty",
		"Cafe,Park,Office",
		"go-example",
	)

	fmt.Println("Created poll:")
	data, _ := json.MarshalIndent(poll, "", "  ")
	fmt.Println(string(data))

	// Cast some votes
	fmt.Println("\nCasting votes...")
	poll.AddVote("Cafe")
	poll.AddVote("Cafe")
	poll.AddVote("Park")
	poll.AddVote("Office")
	poll.AddVote("Cafe")

	// Show results
	fmt.Printf("\nPoll Results:\n")
	fmt.Printf("  Total Votes: %d\n", poll.GetTotalVotes())
	
	leader, leaderVotes := poll.GetLeader()
	fmt.Printf("  Leader: %s (%d votes)\n", leader, leaderVotes)

	percentages := poll.GetPercentages()
	fmt.Println("\nPercentages:")
	for option, pct := range percentages {
		fmt.Printf("  %s: %.1f%%\n", option, pct)
	}

	// Finalize by majority
	fmt.Println("\nFinalizing by majority...")
	winner := poll.FinalizeByMajority()
	fmt.Printf("Poll finalized. Winner: %s\n", winner)
	fmt.Printf("Poll active: %v\n", poll.IsActive)
}

