package benchmark

import (
	"testing"
	"time"

	"github.com/katya-ai/mesh-go/internal/mesh"
)

func BenchmarkGoNodeCreation(b *testing.B) {
	for i := 0; i < b.N; i++ {
		config := &mesh.NodeConfig{
			NodeID:            "bench-go-node",
			ListenAddr:        "127.0.0.1:9000",
			MaxPeers:          10,
			HeartbeatInterval: time.Second * 5,
			EnableEncryption:  true,
		}

		node, err := mesh.NewNode(config)
		if err != nil {
			b.Fatal(err)
		}
		node.Close()
	}
}

func BenchmarkGoMessageSend(b *testing.B) {
	config := &mesh.NodeConfig{
		NodeID:     "bench-send-node",
		ListenAddr: "127.0.0.1:9001",
		MaxPeers:   100,
	}

	node, err := mesh.NewNode(config)
	if err != nil {
		b.Fatal(err)
	}
	defer node.Close()

	message := []byte("Benchmark message")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		err := node.BroadcastMessage(message)
		if err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkGoCryptoEncrypt(b *testing.B) {
	keyPair, err := mesh.GenerateKeyPair()
	if err != nil {
		b.Fatal(err)
	}

	plaintext := []byte("Benchmark crypto message")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, err := mesh.Encrypt(keyPair.PublicKey, plaintext)
		if err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkGoCryptoDecrypt(b *testing.B) {
	keyPair, err := mesh.GenerateKeyPair()
	if err != nil {
		b.Fatal(err)
	}

	plaintext := []byte("Benchmark crypto message")
	ciphertext, err := mesh.Encrypt(keyPair.PublicKey, plaintext)
	if err != nil {
		b.Fatal(err)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, err := mesh.Decrypt(keyPair.PrivateKey, ciphertext)
		if err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkGoFloodingProtocol(b *testing.B) {
	config := &mesh.NodeConfig{
		NodeID:     "bench-flood-node",
		ListenAddr: "127.0.0.1:9002",
		MaxPeers:   50,
	}

	node, err := mesh.NewNode(config)
	if err != nil {
		b.Fatal(err)
	}
	defer node.Close()

	message := []byte("Flood benchmark message")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		err := node.SendFloodMessage(message)
		if err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkGoGossipProtocol(b *testing.B) {
	config := &mesh.NodeConfig{
		NodeID:     "bench-gossip-node",
		ListenAddr: "127.0.0.1:9003",
		MaxPeers:   50,
	}

	node, err := mesh.NewNode(config)
	if err != nil {
		b.Fatal(err)
	}
	defer node.Close()

	message := []byte("Gossip benchmark message")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		err := node.SendGossipMessage(message)
		if err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkGoConsensusProtocol(b *testing.B) {
	config := &mesh.NodeConfig{
		NodeID:     "bench-consensus-node",
		ListenAddr: "127.0.0.1:9004",
		MaxPeers:   20,
	}

	node, err := mesh.NewNode(config)
	if err != nil {
		b.Fatal(err)
	}
	defer node.Close()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		err := node.StartConsensusRound("bench-round")
		if err != nil {
			b.Fatal(err)
		}
	}
}
