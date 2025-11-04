package interop

import (
	"context"
	"testing"
	"time"

	"github.com/katya-ai/mesh-go/pkg/api"
	"github.com/katya-ai/mesh-go/internal/mesh"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestGoNodeCreation(t *testing.T) {
	config := &mesh.NodeConfig{
		NodeID:       "go-test-node",
		ListenAddr:   "127.0.0.1:8080",
		MaxPeers:     10,
		HeartbeatInterval: time.Second * 5,
		EnableEncryption:  true,
	}

	node, err := mesh.NewNode(config)
	require.NoError(t, err)
	require.NotNil(t, node)

	defer node.Close()

	assert.Equal(t, config.NodeID, node.ID())
	assert.True(t, node.IsRunning())
}

func TestGoMessageExchange(t *testing.T) {
	// Create two Go nodes
	config1 := &mesh.NodeConfig{
		NodeID:     "go-node-1",
		ListenAddr: "127.0.0.1:8081",
		MaxPeers:   5,
	}

	config2 := &mesh.NodeConfig{
		NodeID:     "go-node-2",
		ListenAddr: "127.0.0.1:8082",
		MaxPeers:   5,
	}

	node1, err := mesh.NewNode(config1)
	require.NoError(t, err)
	defer node1.Close()

	node2, err := mesh.NewNode(config2)
	require.NoError(t, err)
	defer node2.Close()

	// Connect nodes
	err = node1.ConnectToPeer("127.0.0.1:8082")
	require.NoError(t, err)

	// Wait for connection
	time.Sleep(time.Second * 2)

	peers := node1.GetPeers()
	assert.Contains(t, peers, "go-node-2")

	// Send message
	testMessage := "Hello from Go node 1!"
	err = node1.SendMessage("go-node-2", []byte(testMessage))
	require.NoError(t, err)

	// Wait for message delivery
	time.Sleep(time.Second)

	messages := node2.GetMessages()
	require.Len(t, messages, 1)
	assert.Equal(t, testMessage, string(messages[0].Data))
	assert.Equal(t, "go-node-1", messages[0].From)
}

func TestGoGRPCCalls(t *testing.T) {
	// Start gRPC server
	server := api.NewServer(&api.ServerConfig{
		Address: "127.0.0.1:9090",
	})

	go func() {
		err := server.Start()
		if err != nil {
			t.Logf("Server error: %v", err)
		}
	}()
	defer server.Stop()

	time.Sleep(time.Second) // Wait for server to start

	// Create gRPC client
	client, err := api.NewClient("127.0.0.1:9090")
	require.NoError(t, err)
	defer client.Close()

	// Test health check
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	health, err := client.Health(ctx)
	require.NoError(t, err)
	assert.True(t, health.Healthy)

	// Test peer listing
	peers, err := client.ListPeers(ctx)
	require.NoError(t, err)
	assert.IsType(t, []*api.PeerInfo{}, peers)
}

func TestGoCryptoOperations(t *testing.T) {
	// Test key generation
	keyPair, err := mesh.GenerateKeyPair()
	require.NoError(t, err)
	require.NotNil(t, keyPair)

	// Test encryption/decryption
	plaintext := []byte("Secret message from Go")
	ciphertext, err := mesh.Encrypt(keyPair.PublicKey, plaintext)
	require.NoError(t, err)
	require.NotEqual(t, plaintext, ciphertext)

	decrypted, err := mesh.Decrypt(keyPair.PrivateKey, ciphertext)
	require.NoError(t, err)
	assert.Equal(t, plaintext, decrypted)

	// Test signing/verification
	message := []byte("Message to sign")
	signature, err := mesh.Sign(keyPair.PrivateKey, message)
	require.NoError(t, err)

	valid, err := mesh.Verify(keyPair.PublicKey, message, signature)
	require.NoError(t, err)
	assert.True(t, valid)
}
