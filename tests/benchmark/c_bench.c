#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "mesh/core.h"
#include "mesh/crypto.h"

#define BENCH_ITERATIONS 10000

static double get_time_diff(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) * 1000.0 +
           (end.tv_nsec - start.tv_nsec) / 1000000.0;
}

static void bench_node_creation() {
    printf("Benchmarking C node creation...\n");

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int i = 0; i < BENCH_ITERATIONS; ++i) {
        mesh_node_config config = {
            .node_id = "bench-c-node",
            .listen_addr = "127.0.0.1:9010",
            .max_peers = 10,
            .heartbeat_interval = 5000,
            .enable_encryption = true
        };

        mesh_node* node = mesh_node_create(&config);
        mesh_node_destroy(node);
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = get_time_diff(start, end);

    printf("C node creation: %d iterations in %.2fms (%.2f ops/sec)\n",
           BENCH_ITERATIONS, duration, BENCH_ITERATIONS * 1000.0 / duration);
}

static void bench_message_send() {
    printf("Benchmarking C message send...\n");

    mesh_node_config config = {
        .node_id = "bench-c-send-node",
        .listen_addr = "127.0.0.1:9011",
        .max_peers = 100
    };

    mesh_node* node = mesh_node_create(&config);
    const char* message = "Benchmark message";

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int i = 0; i < BENCH_ITERATIONS; ++i) {
        mesh_node_broadcast_message(node,
                                  (const uint8_t*)message,
                                  strlen(message));
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = get_time_diff(start, end);

    printf("C message send: %d iterations in %.2fms (%.2f msg/sec)\n",
           BENCH_ITERATIONS, duration, BENCH_ITERATIONS * 1000.0 / duration);

    mesh_node_destroy(node);
}

static void bench_crypto_encrypt() {
    printf("Benchmarking C crypto encrypt...\n");

    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    const char* plaintext = "Benchmark crypto message";

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int i = 0; i < BENCH_ITERATIONS; ++i) {
        uint8_t* ciphertext = NULL;
        size_t ciphertext_len = 0;

        mesh_crypto_encrypt(keypair->public_key,
                          (const uint8_t*)plaintext,
                          strlen(plaintext),
                          &ciphertext, &ciphertext_len);

        free(ciphertext);
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = get_time_diff(start, end);

    printf("C crypto encrypt: %d iterations in %.2fms (%.2f ops/sec)\n",
           BENCH_ITERATIONS, duration, BENCH_ITERATIONS * 1000.0 / duration);

    mesh_keypair_destroy(keypair);
}

static void bench_crypto_decrypt() {
    printf("Benchmarking C crypto decrypt...\n");

    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    const char* plaintext = "Benchmark crypto message";

    uint8_t* ciphertext = NULL;
    size_t ciphertext_len = 0;

    mesh_crypto_encrypt(keypair->public_key,
                       (const uint8_t*)plaintext,
                       strlen(plaintext),
                       &ciphertext, &ciphertext_len);

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int i = 0; i < BENCH_ITERATIONS; ++i) {
        uint8_t* decrypted = NULL;
        size_t decrypted_len = 0;

        mesh_crypto_decrypt(keypair->private_key,
                           ciphertext, ciphertext_len,
                           &decrypted, &decrypted_len);

        free(decrypted);
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = get_time_diff(start, end);

    printf("C crypto decrypt: %d iterations in %.2fms (%.2f ops/sec)\n",
           BENCH_ITERATIONS, duration, BENCH_ITERATIONS * 1000.0 / duration);

    free(ciphertext);
    mesh_keypair_destroy(keypair);
}

static void bench_flooding_protocol() {
    printf("Benchmarking C flooding protocol...\n");

    mesh_node_config config = {
        .node_id = "bench-c-flood-node",
        .listen_addr = "127.0.0.1:9012",
        .max_peers = 50
    };

    mesh_node* node = mesh_node_create(&config);
    const char* message = "Flood benchmark message";

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int i = 0; i < BENCH_ITERATIONS; ++i) {
        mesh_node_send_flood_message(node,
                                   (const uint8_t*)message,
                                   strlen(message));
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = get_time_diff(start, end);

    printf("C flooding protocol: %d iterations in %.2fms (%.2f ops/sec)\n",
           BENCH_ITERATIONS, duration, BENCH_ITERATIONS * 1000.0 / duration);

    mesh_node_destroy(node);
}

static void bench_gossip_protocol() {
    printf("Benchmarking C gossip protocol...\n");

    mesh_node_config config = {
        .node_id = "bench-c-gossip-node",
        .listen_addr = "127.0.0.1:9013",
        .max_peers = 50
    };

    mesh_node* node = mesh_node_create(&config);
    const char* message = "Gossip benchmark message";

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int i = 0; i < BENCH_ITERATIONS; ++i) {
        mesh_node_send_gossip_message(node,
                                    (const uint8_t*)message,
                                    strlen(message));
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = get_time_diff(start, end);

    printf("C gossip protocol: %d iterations in %.2fms (%.2f ops/sec)\n",
           BENCH_ITERATIONS, duration, BENCH_ITERATIONS * 1000.0 / duration);

    mesh_node_destroy(node);
}

static void bench_consensus_protocol() {
    printf("Benchmarking C consensus protocol...\n");

    mesh_node_config config = {
        .node_id = "bench-c-consensus-node",
        .listen_addr = "127.0.0.1:9014",
        .max_peers = 20
    };

    mesh_node* node = mesh_node_create(&config);

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int i = 0; i < BENCH_ITERATIONS; ++i) {
        mesh_node_start_consensus_round(node, "bench-round");
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = get_time_diff(start, end);

    printf("C consensus protocol: %d iterations in %.2fms (%.2f ops/sec)\n",
           BENCH_ITERATIONS, duration, BENCH_ITERATIONS * 1000.0 / duration);

    mesh_node_destroy(node);
}

int main(int argc, char* argv[]) {
    printf("Starting C performance benchmarks...\n");

    // Initialize mesh library
    mesh_error init_err = mesh_init();
    if (init_err != MESH_SUCCESS) {
        fprintf(stderr, "Failed to initialize mesh library: %d\n", init_err);
        return 1;
    }

    // Run benchmarks
    bench_node_creation();
    bench_message_send();
    bench_crypto_encrypt();
    bench_crypto_decrypt();
    bench_flooding_protocol();
    bench_gossip_protocol();
    bench_consensus_protocol();

    // Cleanup
    mesh_shutdown();

    printf("C performance benchmarks completed!\n");
    return 0;
}
