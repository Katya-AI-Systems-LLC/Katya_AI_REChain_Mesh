package platform

import (
	"runtime"
	"testing"

	"github.com/katya-ai/mesh-go/internal/mesh"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestPlatformDetection(t *testing.T) {
	// Test that we can detect the current platform
	expectedOS := runtime.GOOS
	expectedArch := runtime.GOARCH

	detectedOS := mesh.GetCurrentOS()
	detectedArch := mesh.GetCurrentArch()

	assert.Equal(t, expectedOS, detectedOS)
	assert.Equal(t, expectedArch, detectedArch)

	t.Logf("Running on %s/%s", detectedOS, detectedArch)
}

func TestCrossPlatformCompatibility(t *testing.T) {
	// Test that core functionality works across different platforms
	config := &mesh.NodeConfig{
		NodeID:     "platform-test-node",
		ListenAddr: "127.0.0.1:9600",
		MaxPeers:   5,
	}

	node, err := mesh.NewNode(config)
	require.NoError(t, err)
	defer node.Close()

	// Test basic operations that should work on all platforms
	assert.True(t, node.IsRunning())

	// Test message sending
	message := []byte("Cross-platform test message")
	err = node.BroadcastMessage(message)
	require.NoError(t, err)

	// Test crypto operations
	keyPair, err := node.GenerateKeys()
	require.NoError(t, err)
	assert.NotNil(t, keyPair)

	// Test encryption/decryption
	plaintext := []byte("Platform compatibility test")
	ciphertext, err := node.Encrypt(keyPair.PublicKey, plaintext)
	require.NoError(t, err)
	assert.NotEqual(t, plaintext, ciphertext)

	decrypted, err := node.Decrypt(keyPair.PrivateKey, ciphertext)
	require.NoError(t, err)
	assert.Equal(t, plaintext, decrypted)
}

func TestNetworkInterfaceDetection(t *testing.T) {
	// Test network interface detection
	interfaces, err := mesh.GetNetworkInterfaces()
	require.NoError(t, err)
	assert.NotEmpty(t, interfaces)

	// Should find at least one interface
	foundLoopback := false
	foundEthernet := false

	for _, iface := range interfaces {
		t.Logf("Interface: %s (%s)", iface.Name, iface.Type)

		if iface.Type == "loopback" {
			foundLoopback = true
		}
		if iface.Type == "ethernet" || iface.Type == "wireless" {
			foundEthernet = true
		}
	}

	assert.True(t, foundLoopback, "Should find loopback interface")
	// Note: Ethernet/WiFi might not be available in all test environments
}

func TestFileSystemCompatibility(t *testing.T) {
	// Test file system operations that should work cross-platform
	tempDir := mesh.GetTempDir()
	assert.NotEmpty(t, tempDir)

	// Test path operations
	testPath := mesh.JoinPaths(tempDir, "katya-mesh-test")
	assert.NotEmpty(t, testPath)

	// Test directory creation
	err := mesh.CreateDirectory(testPath)
	require.NoError(t, err)

	// Test file writing
	testFile := mesh.JoinPaths(testPath, "test.txt")
	testData := []byte("Test data for cross-platform file I/O")

	err = mesh.WriteFile(testFile, testData)
	require.NoError(t, err)

	// Test file reading
	readData, err := mesh.ReadFile(testFile)
	require.NoError(t, err)
	assert.Equal(t, testData, readData)

	// Test file existence
	exists := mesh.FileExists(testFile)
	assert.True(t, exists)

	nonExistentFile := mesh.JoinPaths(testPath, "nonexistent.txt")
	exists = mesh.FileExists(nonExistentFile)
	assert.False(t, exists)

	// Cleanup
	err = mesh.RemoveDirectory(testPath)
	require.NoError(t, err)
}

func TestConcurrencyCompatibility(t *testing.T) {
	// Test that concurrent operations work correctly across platforms
	config := &mesh.NodeConfig{
		NodeID:     "concurrency-test-node",
		ListenAddr: "127.0.0.1:9601",
		MaxPeers:   10,
	}

	node, err := mesh.NewNode(config)
	require.NoError(t, err)
	defer node.Close()

	// Test concurrent message sending
	done := make(chan bool, 10)

	for i := 0; i < 10; i++ {
		go func(id int) {
			message := []byte(fmt.Sprintf("Concurrent message %d", id))
			err := node.BroadcastMessage(message)
			assert.NoError(t, err)
			done <- true
		}(i)
	}

	// Wait for all goroutines to complete
	for i := 0; i < 10; i++ {
		<-done
	}

	// Node should still be running
	assert.True(t, node.IsRunning())
}

func TestMemoryManagement(t *testing.T) {
	// Test memory management across platforms
	config := &mesh.NodeConfig{
		NodeID:     "memory-test-node",
		ListenAddr: "127.0.0.1:9602",
		MaxPeers:   5,
	}

	node, err := mesh.NewNode(config)
	require.NoError(t, err)

	// Test large message handling
	largeMessage := make([]byte, 1024*1024) // 1MB
	for i := range largeMessage {
		largeMessage[i] = byte(i % 256)
	}

	err = node.BroadcastMessage(largeMessage)
	require.NoError(t, err)

	// Test multiple large allocations
	for i := 0; i < 100; i++ {
		message := make([]byte, 64*1024) // 64KB
		for j := range message {
			message[j] = byte((i + j) % 256)
		}

		err = node.BroadcastMessage(message)
		require.NoError(t, err)
	}

	node.Close()
}

func TestTimeHandling(t *testing.T) {
	// Test time handling across platforms
	now := mesh.GetCurrentTime()
	assert.True(t, now > 0)

	// Test timestamp operations
	timestamp1 := mesh.GetTimestampMillis()
	timestamp2 := mesh.GetTimestampMillis()

	assert.True(t, timestamp2 >= timestamp1)

	// Test time formatting
	formatted := mesh.FormatTime(now)
	assert.NotEmpty(t, formatted)

	t.Logf("Current time: %s", formatted)
}

func TestEnvironmentVariables(t *testing.T) {
	// Test environment variable handling
	testKey := "KATYA_MESH_TEST_VAR"
	testValue := "test_value_123"

	// Set environment variable
	err := mesh.SetEnvironmentVariable(testKey, testValue)
	require.NoError(t, err)

	// Get environment variable
	retrievedValue := mesh.GetEnvironmentVariable(testKey)
	assert.Equal(t, testValue, retrievedValue)

	// Test default value
	defaultValue := mesh.GetEnvironmentVariable("NONEXISTENT_VAR", "default")
	assert.Equal(t, "default", defaultValue)

	// Cleanup
	mesh.UnsetEnvironmentVariable(testKey)
}

func TestProcessManagement(t *testing.T) {
	// Test process management functions
	pid := mesh.GetCurrentProcessID()
	assert.True(t, pid > 0)

	processName := mesh.GetCurrentProcessName()
	assert.NotEmpty(t, processName)

	t.Logf("Process: %s (PID: %d)", processName, pid)

	// Test CPU core detection
	cpuCores := mesh.GetCPUCoreCount()
	assert.True(t, cpuCores > 0)

	t.Logf("CPU cores: %d", cpuCores)
}

func TestLocalizationSupport(t *testing.T) {
	// Test basic localization support
	locale := mesh.GetSystemLocale()
	assert.NotEmpty(t, locale)

	t.Logf("System locale: %s", locale)

	// Test timezone handling
	timezone := mesh.GetSystemTimezone()
	assert.NotEmpty(t, timezone)

	t.Logf("System timezone: %s", timezone)
}
