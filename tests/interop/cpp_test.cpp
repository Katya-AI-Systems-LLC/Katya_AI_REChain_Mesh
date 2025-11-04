#include <gtest/gtest.h>
#include <mesh/core.h>
#include <mesh/crypto.h>
#include <memory>
#include <thread>
#include <chrono>

class CppInteropTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Initialize mesh library
        mesh_init();
    }

    void TearDown() override {
        // Cleanup
        mesh_shutdown();
    }
};

TEST_F(CppInteropTest, NodeCreation) {
    mesh_node_config config = {
        .node_id = "cpp-test-node",
        .listen_addr = "127.0.0.1:8083",
        .max_peers = 10,
        .heartbeat_interval = 5000,
        .enable_encryption = true
    };

    mesh_node* node = mesh_node_create(&config);
    ASSERT_NE(node, nullptr);

    EXPECT_STREQ(mesh_node_get_id(node), "cpp-test-node");
    EXPECT_TRUE(mesh_node_is_running(node));

    mesh_node_destroy(node);
}

TEST_F(CppInteropTest, MessageExchange) {
    // Create two C++ nodes
    mesh_node_config config1 = {
        .node_id = "cpp-node-1",
        .listen_addr = "127.0.0.1:8084",
        .max_peers = 5
    };

    mesh_node_config config2 = {
        .node_id = "cpp-node-2",
        .listen_addr = "127.0.0.1:8085",
        .max_peers = 5
    };

    mesh_node* node1 = mesh_node_create(&config1);
    mesh_node* node2 = mesh_node_create(&config2);

    ASSERT_NE(node1, nullptr);
    ASSERT_NE(node2, nullptr);

    // Connect nodes
    mesh_error err = mesh_node_connect_to_peer(node1, "127.0.0.1:8085");
    EXPECT_EQ(err, MESH_SUCCESS);

    // Wait for connection
    std::this_thread::sleep_for(std::chrono::seconds(2));

    // Check peers
    mesh_peer_list* peers = mesh_node_get_peers(node1);
    ASSERT_NE(peers, nullptr);
    EXPECT_EQ(peers->count, 1);
    EXPECT_STREQ(peers->peers[0].node_id, "cpp-node-2");

    mesh_peer_list_destroy(peers);

    // Send message
    const char* test_message = "Hello from C++ node 1!";
    err = mesh_node_send_message(node1, "cpp-node-2",
                                reinterpret_cast<const uint8_t*>(test_message),
                                strlen(test_message));
    EXPECT_EQ(err, MESH_SUCCESS);

    // Wait for message delivery
    std::this_thread::sleep_for(std::chrono::seconds(1));

    // Check received messages
    mesh_message_list* messages = mesh_node_get_messages(node2);
    ASSERT_NE(messages, nullptr);
    EXPECT_EQ(messages->count, 1);
    EXPECT_STREQ(reinterpret_cast<const char*>(messages->messages[0].data), test_message);
    EXPECT_STREQ(messages->messages[0].from, "cpp-node-1");

    mesh_message_list_destroy(messages);
    mesh_node_destroy(node1);
    mesh_node_destroy(node2);
}

TEST_F(CppInteropTest, CryptoOperations) {
    // Test key generation
    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    ASSERT_NE(keypair, nullptr);

    // Test encryption/decryption
    const char* plaintext = "Secret message from C++";
    size_t plaintext_len = strlen(plaintext);

    uint8_t* ciphertext = nullptr;
    size_t ciphertext_len = 0;

    mesh_error err = mesh_crypto_encrypt(keypair->public_key,
                                        reinterpret_cast<const uint8_t*>(plaintext),
                                        plaintext_len,
                                        &ciphertext, &ciphertext_len);
    EXPECT_EQ(err, MESH_SUCCESS);
    EXPECT_NE(ciphertext, nullptr);
    EXPECT_GT(ciphertext_len, 0);

    uint8_t* decrypted = nullptr;
    size_t decrypted_len = 0;

    err = mesh_crypto_decrypt(keypair->private_key,
                             ciphertext, ciphertext_len,
                             &decrypted, &decrypted_len);
    EXPECT_EQ(err, MESH_SUCCESS);
    EXPECT_EQ(decrypted_len, plaintext_len);
    EXPECT_EQ(memcmp(decrypted, plaintext, plaintext_len), 0);

    // Test signing/verification
    const char* message = "Message to sign";
    size_t message_len = strlen(message);

    uint8_t* signature = nullptr;
    size_t signature_len = 0;

    err = mesh_crypto_sign(keypair->private_key,
                          reinterpret_cast<const uint8_t*>(message),
                          message_len,
                          &signature, &signature_len);
    EXPECT_EQ(err, MESH_SUCCESS);

    bool valid = mesh_crypto_verify(keypair->public_key,
                                   reinterpret_cast<const uint8_t*>(message),
                                   message_len,
                                   signature, signature_len);
    EXPECT_TRUE(valid);

    // Cleanup
    free(ciphertext);
    free(decrypted);
    free(signature);
    mesh_keypair_destroy(keypair);
}

TEST_F(CppInteropTest, PerformanceBenchmark) {
    mesh_node_config config = {
        .node_id = "cpp-bench-node",
        .listen_addr = "127.0.0.1:8086",
        .max_peers = 100
    };

    mesh_node* node = mesh_node_create(&config);
    ASSERT_NE(node, nullptr);

    // Benchmark message processing
    auto start = std::chrono::high_resolution_clock::now();

    const int num_messages = 1000;
    for (int i = 0; i < num_messages; ++i) {
        char msg[64];
        snprintf(msg, sizeof(msg), "Benchmark message %d", i);

        mesh_error err = mesh_node_broadcast_message(node,
                                                   reinterpret_cast<const uint8_t*>(msg),
                                                   strlen(msg));
        ASSERT_EQ(err, MESH_SUCCESS);
    }

    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

    std::cout << "Processed " << num_messages << " messages in "
              << duration.count() << "ms ("
              << (num_messages * 1000.0 / duration.count()) << " msg/sec)"
              << std::endl;

    mesh_node_destroy(node);
}
