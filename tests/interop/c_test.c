#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "mesh/core.h"
#include "mesh/crypto.h"

static void test_node_creation(void) {
    printf("Testing C node creation...\n");

    mesh_node_config config = {
        .node_id = "c-test-node",
        .listen_addr = "127.0.0.1:8087",
        .max_peers = 10,
        .heartbeat_interval = 5000,
        .enable_encryption = true
    };

    mesh_node* node = mesh_node_create(&config);
    assert(node != NULL);

    const char* node_id = mesh_node_get_id(node);
    assert(strcmp(node_id, "c-test-node") == 0);
    assert(mesh_node_is_running(node) == true);

    mesh_node_destroy(node);
    printf("✓ C node creation test passed\n");
}

static void test_message_exchange(void) {
    printf("Testing C message exchange...\n");

    // Create two C nodes
    mesh_node_config config1 = {
        .node_id = "c-node-1",
        .listen_addr = "127.0.0.1:8088",
        .max_peers = 5
    };

    mesh_node_config config2 = {
        .node_id = "c-node-2",
        .listen_addr = "127.0.0.1:8089",
        .max_peers = 5
    };

    mesh_node* node1 = mesh_node_create(&config1);
    mesh_node* node2 = mesh_node_create(&config2);

    assert(node1 != NULL);
    assert(node2 != NULL);

    // Connect nodes
    mesh_error err = mesh_node_connect_to_peer(node1, "127.0.0.1:8089");
    assert(err == MESH_SUCCESS);

    // Wait for connection
    sleep(2);

    // Check peers
    mesh_peer_list* peers = mesh_node_get_peers(node1);
    assert(peers != NULL);
    assert(peers->count == 1);
    assert(strcmp(peers->peers[0].node_id, "c-node-2") == 0);

    mesh_peer_list_destroy(peers);

    // Send message
    const char* test_message = "Hello from C node 1!";
    err = mesh_node_send_message(node1, "c-node-2",
                                (const uint8_t*)test_message,
                                strlen(test_message));
    assert(err == MESH_SUCCESS);

    // Wait for message delivery
    sleep(1);

    // Check received messages
    mesh_message_list* messages = mesh_node_get_messages(node2);
    assert(messages != NULL);
    assert(messages->count == 1);
    assert(strcmp((const char*)messages->messages[0].data, test_message) == 0);
    assert(strcmp(messages->messages[0].from, "c-node-1") == 0);

    mesh_message_list_destroy(messages);
    mesh_node_destroy(node1);
    mesh_node_destroy(node2);
    printf("✓ C message exchange test passed\n");
}

static void test_crypto_operations(void) {
    printf("Testing C crypto operations...\n");

    // Test key generation
    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    assert(keypair != NULL);

    // Test encryption/decryption
    const char* plaintext = "Secret message from C";
    size_t plaintext_len = strlen(plaintext);

    uint8_t* ciphertext = NULL;
    size_t ciphertext_len = 0;

    mesh_error err = mesh_crypto_encrypt(keypair->public_key,
                                        (const uint8_t*)plaintext,
                                        plaintext_len,
                                        &ciphertext, &ciphertext_len);
    assert(err == MESH_SUCCESS);
    assert(ciphertext != NULL);
    assert(ciphertext_len > 0);

    uint8_t* decrypted = NULL;
    size_t decrypted_len = 0;

    err = mesh_crypto_decrypt(keypair->private_key,
                             ciphertext, ciphertext_len,
                             &decrypted, &decrypted_len);
    assert(err == MESH_SUCCESS);
    assert(decrypted_len == plaintext_len);
    assert(memcmp(decrypted, plaintext, plaintext_len) == 0);

    // Test signing/verification
    const char* message = "Message to sign";
    size_t message_len = strlen(message);

    uint8_t* signature = NULL;
    size_t signature_len = 0;

    err = mesh_crypto_sign(keypair->private_key,
                          (const uint8_t*)message,
                          message_len,
                          &signature, &signature_len);
    assert(err == MESH_SUCCESS);

    bool valid = mesh_crypto_verify(keypair->public_key,
                                   (const uint8_t*)message,
                                   message_len,
                                   signature, signature_len);
    assert(valid == true);

    // Cleanup
    free(ciphertext);
    free(decrypted);
    free(signature);
    mesh_keypair_destroy(keypair);
    printf("✓ C crypto operations test passed\n");
}

static void test_performance_benchmark(void) {
    printf("Testing C performance benchmark...\n");

    mesh_node_config config = {
        .node_id = "c-bench-node",
        .listen_addr = "127.0.0.1:8090",
        .max_peers = 100
    };

    mesh_node* node = mesh_node_create(&config);
    assert(node != NULL);

    // Benchmark message processing
    clock_t start = clock();

    const int num_messages = 1000;
    for (int i = 0; i < num_messages; ++i) {
        char msg[64];
        snprintf(msg, sizeof(msg), "Benchmark message %d", i);

        mesh_error err = mesh_node_broadcast_message(node,
                                                   (const uint8_t*)msg,
                                                   strlen(msg));
        assert(err == MESH_SUCCESS);
    }

    clock_t end = clock();
    double duration = (double)(end - start) / CLOCKS_PER_SEC * 1000.0;

    printf("Processed %d messages in %.2fms (%.2f msg/sec)\n",
           num_messages, duration, num_messages * 1000.0 / duration);

    mesh_node_destroy(node);
    printf("✓ C performance benchmark test passed\n");
}

int main(int argc, char* argv[]) {
    printf("Starting C interoperability tests...\n");

    // Initialize mesh library
    mesh_error init_err = mesh_init();
    if (init_err != MESH_SUCCESS) {
        fprintf(stderr, "Failed to initialize mesh library: %d\n", init_err);
        return 1;
    }

    // Run tests
    test_node_creation();
    test_message_exchange();
    test_crypto_operations();
    test_performance_benchmark();

    // Cleanup
    mesh_shutdown();

    printf("All C interoperability tests passed! ✓\n");
    return 0;
}
