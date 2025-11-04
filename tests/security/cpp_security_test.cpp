#include <gtest/gtest.h>
#include <mesh/core.h>
#include <mesh/crypto.h>
#include <openssl/sha.h>
#include <cstring>
#include <vector>
#include <memory>

class SecurityTest : public ::testing::Test {
protected:
    void SetUp() override {
        mesh_init();
    }

    void TearDown() override {
        mesh_shutdown();
    }
};

TEST_F(SecurityTest, EncryptionDecryption) {
    // Generate keypair
    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    ASSERT_NE(keypair, nullptr);

    const char* plaintext = "Secret message for encryption test";
    size_t plaintext_len = strlen(plaintext);

    // Encrypt
    uint8_t* ciphertext = nullptr;
    size_t ciphertext_len = 0;

    mesh_error err = mesh_crypto_encrypt(keypair->public_key,
                                        reinterpret_cast<const uint8_t*>(plaintext),
                                        plaintext_len,
                                        &ciphertext, &ciphertext_len);
    EXPECT_EQ(err, MESH_SUCCESS);
    EXPECT_NE(ciphertext, nullptr);
    EXPECT_GT(ciphertext_len, 0);

    // Ciphertext should be different from plaintext
    EXPECT_NE(memcmp(ciphertext, plaintext, plaintext_len), 0);

    // Decrypt
    uint8_t* decrypted = nullptr;
    size_t decrypted_len = 0;

    err = mesh_crypto_decrypt(keypair->private_key,
                             ciphertext, ciphertext_len,
                             &decrypted, &decrypted_len);
    EXPECT_EQ(err, MESH_SUCCESS);
    EXPECT_EQ(decrypted_len, plaintext_len);
    EXPECT_EQ(memcmp(decrypted, plaintext, plaintext_len), 0);

    // Cleanup
    free(ciphertext);
    free(decrypted);
    mesh_keypair_destroy(keypair);
}

TEST_F(SecurityTest, SignatureVerification) {
    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    ASSERT_NE(keypair, nullptr);

    const char* message = "Message to sign";
    size_t message_len = strlen(message);

    // Sign
    uint8_t* signature = nullptr;
    size_t signature_len = 0;

    mesh_error err = mesh_crypto_sign(keypair->private_key,
                                     reinterpret_cast<const uint8_t*>(message),
                                     message_len,
                                     &signature, &signature_len);
    EXPECT_EQ(err, MESH_SUCCESS);
    EXPECT_NE(signature, nullptr);

    // Verify with correct key
    bool valid = mesh_crypto_verify(keypair->public_key,
                                   reinterpret_cast<const uint8_t*>(message),
                                   message_len,
                                   signature, signature_len);
    EXPECT_TRUE(valid);

    // Verify with wrong key
    mesh_keypair* wrong_keypair = mesh_crypto_generate_keypair();
    valid = mesh_crypto_verify(wrong_keypair->public_key,
                              reinterpret_cast<const uint8_t*>(message),
                              message_len,
                              signature, signature_len);
    EXPECT_FALSE(valid);

    // Verify with tampered message
    const char* tampered = "Tampered message";
    valid = mesh_crypto_verify(keypair->public_key,
                              reinterpret_cast<const uint8_t*>(tampered),
                              strlen(tampered),
                              signature, signature_len);
    EXPECT_FALSE(valid);

    // Cleanup
    free(signature);
    mesh_keypair_destroy(keypair);
    mesh_keypair_destroy(wrong_keypair);
}

TEST_F(SecurityTest, KeyExchange) {
    // Generate X25519 keypairs
    mesh_keypair* alice_keys = mesh_crypto_generate_x25519_keypair();
    mesh_keypair* bob_keys = mesh_crypto_generate_x25519_keypair();

    ASSERT_NE(alice_keys, nullptr);
    ASSERT_NE(bob_keys, nullptr);

    // Compute shared secrets
    uint8_t* alice_shared = nullptr;
    size_t alice_shared_len = 0;

    mesh_error err = mesh_crypto_compute_shared_secret(alice_keys->private_key,
                                                      bob_keys->public_key,
                                                      &alice_shared, &alice_shared_len);
    EXPECT_EQ(err, MESH_SUCCESS);

    uint8_t* bob_shared = nullptr;
    size_t bob_shared_len = 0;

    err = mesh_crypto_compute_shared_secret(bob_keys->private_key,
                                           alice_keys->public_key,
                                           &bob_shared, &bob_shared_len);
    EXPECT_EQ(err, MESH_SUCCESS);

    // Shared secrets should be equal
    EXPECT_EQ(alice_shared_len, bob_shared_len);
    EXPECT_EQ(memcmp(alice_shared, bob_shared, alice_shared_len), 0);

    // Cleanup
    free(alice_shared);
    free(bob_shared);
    mesh_keypair_destroy(alice_keys);
    mesh_keypair_destroy(bob_keys);
}

TEST_F(SecurityTest, BufferOverflowProtection) {
    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    ASSERT_NE(keypair, nullptr);

    // Test with very large input
    const size_t large_size = 1024 * 1024; // 1MB
    std::vector<uint8_t> large_plaintext(large_size, 'A');

    uint8_t* ciphertext = nullptr;
    size_t ciphertext_len = 0;

    mesh_error err = mesh_crypto_encrypt(keypair->public_key,
                                        large_plaintext.data(),
                                        large_plaintext.size(),
                                        &ciphertext, &ciphertext_len);
    EXPECT_EQ(err, MESH_SUCCESS);

    uint8_t* decrypted = nullptr;
    size_t decrypted_len = 0;

    err = mesh_crypto_decrypt(keypair->private_key,
                             ciphertext, ciphertext_len,
                             &decrypted, &decrypted_len);
    EXPECT_EQ(err, MESH_SUCCESS);
    EXPECT_EQ(decrypted_len, large_plaintext.size());
    EXPECT_EQ(memcmp(decrypted, large_plaintext.data(), large_plaintext.size()), 0);

    // Cleanup
    free(ciphertext);
    free(decrypted);
    mesh_keypair_destroy(keypair);
}

TEST_F(SecurityTest, HashIntegrity) {
    const char* test_data = "Test data for hashing";
    const char* different_data = "Different test data";

    uint8_t hash1[SHA256_DIGEST_LENGTH];
    uint8_t hash2[SHA256_DIGEST_LENGTH];
    uint8_t hash3[SHA256_DIGEST_LENGTH];

    SHA256(reinterpret_cast<const uint8_t*>(test_data), strlen(test_data), hash1);
    SHA256(reinterpret_cast<const uint8_t*>(test_data), strlen(test_data), hash2);
    SHA256(reinterpret_cast<const uint8_t*>(different_data), strlen(different_data), hash3);

    // Same data should produce same hash
    EXPECT_EQ(memcmp(hash1, hash2, SHA256_DIGEST_LENGTH), 0);

    // Different data should produce different hash
    EXPECT_NE(memcmp(hash1, hash3, SHA256_DIGEST_LENGTH), 0);
}

TEST_F(SecurityTest, SecureRandomGeneration) {
    const size_t random_size = 32;
    uint8_t random1[random_size];
    uint8_t random2[random_size];

    // Generate random data
    EXPECT_EQ(mesh_crypto_random_bytes(random1, random_size), MESH_SUCCESS);
    EXPECT_EQ(mesh_crypto_random_bytes(random2, random_size), MESH_SUCCESS);

    // Random data should be different (with very high probability)
    EXPECT_NE(memcmp(random1, random2, random_size), 0);
}

TEST_F(SecurityTest, MemoryLeakPrevention) {
    // Test that repeated operations don't leak memory
    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    ASSERT_NE(keypair, nullptr);

    const char* test_message = "Test message for memory leak test";

    // Perform many encrypt/decrypt operations
    for (int i = 0; i < 1000; ++i) {
        uint8_t* ciphertext = nullptr;
        size_t ciphertext_len = 0;

        mesh_error err = mesh_crypto_encrypt(keypair->public_key,
                                           reinterpret_cast<const uint8_t*>(test_message),
                                           strlen(test_message),
                                           &ciphertext, &ciphertext_len);
        EXPECT_EQ(err, MESH_SUCCESS);

        uint8_t* decrypted = nullptr;
        size_t decrypted_len = 0;

        err = mesh_crypto_decrypt(keypair->private_key,
                                ciphertext, ciphertext_len,
                                &decrypted, &decrypted_len);
        EXPECT_EQ(err, MESH_SUCCESS);

        free(ciphertext);
        free(decrypted);
    }

    mesh_keypair_destroy(keypair);
}

TEST_F(SecurityTest, TimingAttackResistance) {
    mesh_keypair* keypair = mesh_crypto_generate_keypair();
    ASSERT_NE(keypair, nullptr);

    const char* correct_message = "Correct message";
    const char* wrong_message = "Wrong message";

    // Sign correct message
    uint8_t* signature = nullptr;
    size_t signature_len = 0;

    mesh_error err = mesh_crypto_sign(keypair->private_key,
                                     reinterpret_cast<const uint8_t*>(correct_message),
                                     strlen(correct_message),
                                     &signature, &signature_len);
    EXPECT_EQ(err, MESH_SUCCESS);

    // Time verification of correct message
    auto start_correct = std::chrono::high_resolution_clock::now();
    bool valid_correct = mesh_crypto_verify(keypair->public_key,
                                          reinterpret_cast<const uint8_t*>(correct_message),
                                          strlen(correct_message),
                                          signature, signature_len);
    auto end_correct = std::chrono::high_resolution_clock::now();

    // Time verification of wrong message
    auto start_wrong = std::chrono::high_resolution_clock::now();
    bool valid_wrong = mesh_crypto_verify(keypair->public_key,
                                        reinterpret_cast<const uint8_t*>(wrong_message),
                                        strlen(wrong_message),
                                        signature, signature_len);
    auto end_wrong = std::chrono::high_resolution_clock::now();

    auto duration_correct = std::chrono::duration_cast<std::chrono::nanoseconds>(
        end_correct - start_correct).count();
    auto duration_wrong = std::chrono::duration_cast<std::chrono::nanoseconds>(
        end_wrong - start_wrong).count();

    EXPECT_TRUE(valid_correct);
    EXPECT_FALSE(valid_wrong);

    // Timing difference should be minimal (within 10% for security)
    double ratio = static_cast<double>(duration_wrong) / duration_correct;
    EXPECT_NEAR(ratio, 1.0, 0.1);

    free(signature);
    mesh_keypair_destroy(keypair);
}
