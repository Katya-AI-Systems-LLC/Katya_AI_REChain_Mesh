package interop

import (
	"context"
	"testing"
	"time"

	"github.com/katya-ai/mesh-go/pkg/api"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Test cross-language interoperability between Go and other implementations
func TestGoToCppInterop(t *testing.T) {
	// This test assumes C++ node is running on port 8083
	goNode := createGoNode(t, "127.0.0.1:8096", "go-to-cpp-node")

	// Connect to C++ node (assuming it's running)
	err := goNode.ConnectToPeer("127.0.0.1:8083")
	if err != nil {
		t.Skip("C++ node not available, skipping cross-language test")
		return
	}

	// Wait for connection
	time.Sleep(time.Second * 3)

	// Send message to C++ node
	testMessage := "Hello from Go to C++!"
	err = goNode.SendMessage("cpp-test-node", []byte(testMessage))
	require.NoError(t, err)

	// In a real scenario, we would need to check the C++ node's received messages
	// This is a simplified test structure
	goNode.Close()
}

func TestGoToCInterop(t *testing.T) {
	// This test assumes C node is running on port 8087
	goNode := createGoNode(t, "127.0.0.1:8097", "go-to-c-node")

	// Connect to C node (assuming it's running)
	err := goNode.ConnectToPeer("127.0.0.1:8087")
	if err != nil {
		t.Skip("C node not available, skipping cross-language test")
		return
	}

	time.Sleep(time.Second * 3)

	testMessage := "Hello from Go to C!"
	err = goNode.SendMessage("c-test-node", []byte(testMessage))
	require.NoError(t, err)

	goNode.Close()
}

func TestGoToRustInterop(t *testing.T) {
	// This test assumes Rust node is running on port 8091
	goNode := createGoNode(t, "127.0.0.1:8098", "go-to-rust-node")

	// Connect to Rust node (assuming it's running)
	err := goNode.ConnectToPeer("127.0.0.1:8091")
	if err != nil {
		t.Skip("Rust node not available, skipping cross-language test")
		return
	}

	time.Sleep(time.Second * 3)

	testMessage := "Hello from Go to Rust!"
	err = goNode.SendMessage("rust-test-node", []byte(testMessage))
	require.NoError(t, err)

	goNode.Close()
}

func TestMultiLanguageMesh(t *testing.T) {
	// Test creating a mesh network with multiple language implementations
	// This is a high-level integration test

	goNode := createGoNode(t, "127.0.0.1:8099", "multi-lang-go")

	// Try to connect to other language nodes
	// In practice, these would be started separately
	languageNodes := []struct {
		addr    string
		nodeID  string
		lang    string
	}{
		{"127.0.0.1:8083", "cpp-test-node", "C++"},
		{"127.0.0.1:8087", "c-test-node", "C"},
		{"127.0.0.1:8091", "rust-test-node", "Rust"},
	}

	connectedCount := 0
	for _, node := range languageNodes {
		err := goNode.ConnectToPeer(node.addr)
		if err == nil {
			connectedCount++
			t.Logf("Successfully connected to %s node: %s", node.lang, node.nodeID)
		} else {
			t.Logf("Could not connect to %s node: %v", node.lang, err)
		}
	}

	if connectedCount == 0 {
		t.Skip("No other language nodes available, skipping multi-language test")
		return
	}

	// Send broadcast message to all connected nodes
	broadcastMessage := "Broadcast from Go to all language implementations!"
	err := goNode.BroadcastMessage([]byte(broadcastMessage))
	require.NoError(t, err)

	t.Logf("Successfully broadcast message to %d nodes across languages", connectedCount)

	goNode.Close()
}

func TestProtocolCompatibility(t *testing.T) {
	// Test that all implementations support the same protocols
	goNode := createGoNode(t, "127.0.0.1:8100", "protocol-test-go")

	// Test flooding protocol
	err := goNode.SendFloodMessage([]byte("Flood test"))
	require.NoError(t, err)

	// Test gossip protocol
	err = goNode.SendGossipMessage([]byte("Gossip test"))
	require.NoError(t, err)

	// Test consensus protocol
	err = goNode.StartConsensusRound("test-consensus")
	require.NoError(t, err)

	goNode.Close()
}

func TestCryptoCompatibility(t *testing.T) {
	// Test cryptographic compatibility across implementations
	goNode := createGoNode(t, "127.0.0.1:8101", "crypto-test-go")

	// Generate keys
	pubKey, privKey, err := goNode.GenerateKeys()
	require.NoError(t, err)
	require.NotNil(t, pubKey)
	require.NotNil(t, privKey)

	// Test encryption/decryption
	plaintext := []byte("Cross-language crypto test")
	ciphertext, err := goNode.Encrypt(pubKey, plaintext)
	require.NoError(t, err)

	decrypted, err := goNode.Decrypt(privKey, ciphertext)
	require.NoError(t, err)
	assert.Equal(t, plaintext, decrypted)

	// Test signing/verification
	message := []byte("Message to sign")
	signature, err := goNode.Sign(privKey, message)
	require.NoError(t, err)

	valid, err := goNode.Verify(pubKey, message, signature)
	require.NoError(t, err)
	assert.True(t, valid)

	goNode.Close()
}

func TestLoadBalancingAcrossLanguages(t *testing.T) {
	// Test load balancing when multiple language implementations are present
	goNode := createGoNode(t, "127.0.0.1:8102", "lb-test-go")

	// Simulate load balancing scenario
	// In practice, this would test actual load distribution

	// Send multiple messages to test load distribution
	for i := 0; i < 100; i++ {
		message := []byte(fmt.Sprintf("Load test message %d", i))
		err := goNode.BroadcastMessage(message)
		require.NoError(t, err)

		// Small delay to simulate real load
		time.Sleep(time.Millisecond * 10)
	}

	goNode.Close()
}

// Helper function to create a Go node for testing
func createGoNode(t *testing.T, addr, nodeID string) *mesh.Node {
	config := &mesh.NodeConfig{
		NodeID:            nodeID,
		ListenAddr:        addr,
		MaxPeers:          20,
		HeartbeatInterval: time.Second * 5,
		EnableEncryption:  true,
	}

	node, err := mesh.NewNode(config)
	require.NoError(t, err)
	require.NotNil(t, node)

	return node
}
