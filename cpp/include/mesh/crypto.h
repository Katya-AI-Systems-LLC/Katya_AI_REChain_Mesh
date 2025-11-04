#ifndef MESH_CRYPTO_H
#define MESH_CRYPTO_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Crypto types
typedef struct mesh_crypto_context mesh_crypto_context_t;
typedef uint8_t mesh_key_t[32];
typedef uint8_t mesh_nonce_t[12];
typedef uint8_t mesh_signature_t[64];
typedef uint8_t mesh_hash_t[32];

// Error codes
typedef enum {
    MESH_CRYPTO_SUCCESS = 0,
    MESH_CRYPTO_ERROR_INVALID_KEY = -1,
    MESH_CRYPTO_ERROR_INVALID_DATA = -2,
    MESH_CRYPTO_ERROR_ENCRYPTION_FAILED = -3,
    MESH_CRYPTO_ERROR_DECRYPTION_FAILED = -4,
    MESH_CRYPTO_ERROR_SIGNATURE_INVALID = -5,
    MESH_CRYPTO_ERROR_OUT_OF_MEMORY = -6,
} mesh_crypto_error_t;

// Crypto context management
mesh_crypto_context_t* mesh_crypto_create_context();
void mesh_crypto_destroy_context(mesh_crypto_context_t* ctx);

// AES-GCM encryption/decryption
mesh_crypto_error_t mesh_crypto_aes_gcm_encrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* plaintext,
    size_t plaintext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* ciphertext,
    size_t* ciphertext_len);

mesh_crypto_error_t mesh_crypto_aes_gcm_decrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* ciphertext,
    size_t ciphertext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* plaintext,
    size_t* plaintext_len);

// Ed25519 signature operations
mesh_crypto_error_t mesh_crypto_ed25519_keypair_generate(
    mesh_key_t public_key,
    mesh_key_t private_key);

mesh_crypto_error_t mesh_crypto_ed25519_sign(
    const mesh_key_t private_key,
    const uint8_t* message,
    size_t message_len,
    mesh_signature_t signature);

mesh_crypto_error_t mesh_crypto_ed25519_verify(
    const mesh_key_t public_key,
    const uint8_t* message,
    size_t message_len,
    const mesh_signature_t signature);

// ChaCha20-Poly1305 encryption/decryption
mesh_crypto_error_t mesh_crypto_chacha20_poly1305_encrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* plaintext,
    size_t plaintext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* ciphertext,
    size_t* ciphertext_len);

mesh_crypto_error_t mesh_crypto_chacha20_poly1305_decrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* ciphertext,
    size_t ciphertext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* plaintext,
    size_t* plaintext_len);

// HKDF key derivation
mesh_crypto_error_t mesh_crypto_hkdf_sha256(
    const uint8_t* key,
    size_t key_len,
    const uint8_t* salt,
    size_t salt_len,
    const uint8_t* info,
    size_t info_len,
    uint8_t* output,
    size_t output_len);

// Hash functions
mesh_crypto_error_t mesh_crypto_sha256(
    const uint8_t* data,
    size_t data_len,
    mesh_hash_t hash);

mesh_crypto_error_t mesh_crypto_sha512(
    const uint8_t* data,
    size_t data_len,
    uint8_t* hash,
    size_t hash_len);

// Random number generation
mesh_crypto_error_t mesh_crypto_random_bytes(uint8_t* buffer, size_t length);

// Key derivation utilities
mesh_crypto_error_t mesh_crypto_derive_mesh_keys(
    const uint8_t* master_key,
    size_t master_key_len,
    const char* node_id,
    mesh_key_t encryption_key,
    mesh_key_t auth_key);

mesh_crypto_error_t mesh_crypto_derive_session_keys(
    const uint8_t* shared_secret,
    size_t shared_secret_len,
    const char* peer_id1,
    const char* peer_id2,
    mesh_key_t key1,
    mesh_key_t key2);

// Utility functions
const char* mesh_crypto_error_string(mesh_crypto_error_t error);
void mesh_crypto_get_version(int* major, int* minor, int* patch);

#ifdef __cplusplus
}
#endif

#endif // MESH_CRYPTO_H
