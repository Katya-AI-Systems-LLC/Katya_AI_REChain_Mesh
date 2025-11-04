#include <benchmark/benchmark.h>
#include <mesh/core.h>
#include <mesh/crypto.h>
#include <cstring>

static void BM_CppNodeCreation(benchmark::State& state) {
    mesh_init();

    for (auto _ : state) {
        mesh_node_config config = {
            .node_id = "bench-cpp-node",
            .listen_addr = "127.0.0.1:9005",
            .max_peers = 10,
            .heartbeat_interval = 5000,
            .enable_encryption = true
        };

        mesh_node* node = mesh_node_create(&config);
        benchmark::DoNotOptimize(node);
        mesh_node_destroy(node);
    }

    mesh_shutdown();
}
BENCHMARK(BM_CppNodeCreation);

static void BM_CppMessageSend(benchmark::State& state) {
    mesh_init();

    mesh_node_config config = {
        .node_id = "bench-cpp-send-node",
        .listen_addr = "127.0.0.1:9006",
        .max_peers = 100
    };

    mesh_node* node = mesh_node_create(&config);
    const char* message = "Benchmark message";

    for (auto _ : state) {
        mesh_error err = mesh_node_broadcast_message(node,
                                                   reinterpret_cast<const uint8_t*>(message),
                                                   strlen(message));
        benchmark::DoNotOptimize(err);
    }

    mesh_node_destroy(node);
    mesh_shutdown();
}
BENCHMARK(BM_CppMessageSend);

static void BM_CppCryptoEncrypt(benchmark::State& state) {
    mesh_init();

    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    const char* plaintext = "Benchmark crypto message";
    size_t plaintext_len = strlen(plaintext);

    for (auto _ : state) {
        uint8_t* ciphertext = nullptr;
        size_t ciphertext_len = 0;

        mesh_error err = mesh_crypto_encrypt(keypair->public_key,
                                           reinterpret_cast<const uint8_t*>(plaintext),
                                           plaintext_len,
                                           &ciphertext, &ciphertext_len);
        benchmark::DoNotOptimize(ciphertext);

        free(ciphertext);
    }

    mesh_keypair_destroy(keypair);
    mesh_shutdown();
}
BENCHMARK(BM_CppCryptoEncrypt);

static void BM_CppCryptoDecrypt(benchmark::State& state) {
    mesh_init();

    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    const char* plaintext = "Benchmark crypto message";
    size_t plaintext_len = strlen(plaintext);

    uint8_t* ciphertext = nullptr;
    size_t ciphertext_len = 0;

    mesh_crypto_encrypt(keypair->public_key,
                       reinterpret_cast<const uint8_t*>(plaintext),
                       plaintext_len,
                       &ciphertext, &ciphertext_len);

    for (auto _ : state) {
        uint8_t* decrypted = nullptr;
        size_t decrypted_len = 0;

        mesh_error err = mesh_crypto_decrypt(keypair->private_key,
                                           ciphertext, ciphertext_len,
                                           &decrypted, &decrypted_len);
        benchmark::DoNotOptimize(decrypted);

        free(decrypted);
    }

    free(ciphertext);
    mesh_keypair_destroy(keypair);
    mesh_shutdown();
}
BENCHMARK(BM_CppCryptoDecrypt);

static void BM_CppFloodingProtocol(benchmark::State& state) {
    mesh_init();

    mesh_node_config config = {
        .node_id = "bench-cpp-flood-node",
        .listen_addr = "127.0.0.1:9007",
        .max_peers = 50
    };

    mesh_node* node = mesh_node_create(&config);
    const char* message = "Flood benchmark message";

    for (auto _ : state) {
        mesh_error err = mesh_node_send_flood_message(node,
                                                    reinterpret_cast<const uint8_t*>(message),
                                                    strlen(message));
        benchmark::DoNotOptimize(err);
    }

    mesh_node_destroy(node);
    mesh_shutdown();
}
BENCHMARK(BM_CppFloodingProtocol);

static void BM_CppGossipProtocol(benchmark::State& state) {
    mesh_init();

    mesh_node_config config = {
        .node_id = "bench-cpp-gossip-node",
        .listen_addr = "127.0.0.1:9008",
        .max_peers = 50
    };

    mesh_node* node = mesh_node_create(&config);
    const char* message = "Gossip benchmark message";

    for (auto _ : state) {
        mesh_error err = mesh_node_send_gossip_message(node,
                                                     reinterpret_cast<const uint8_t*>(message),
                                                     strlen(message));
        benchmark::DoNotOptimize(err);
    }

    mesh_node_destroy(node);
    mesh_shutdown();
}
BENCHMARK(BM_CppGossipProtocol);

static void BM_CppConsensusProtocol(benchmark::State& state) {
    mesh_init();

    mesh_node_config config = {
        .node_id = "bench-cpp-consensus-node",
        .listen_addr = "127.0.0.1:9009",
        .max_peers = 20
    };

    mesh_node* node = mesh_node_create(&config);

    for (auto _ : state) {
        mesh_error err = mesh_node_start_consensus_round(node, "bench-round");
        benchmark::DoNotOptimize(err);
    }

    mesh_node_destroy(node);
    mesh_shutdown();
}
BENCHMARK(BM_CppConsensusProtocol);

BENCHMARK_MAIN();
