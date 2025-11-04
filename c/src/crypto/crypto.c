#include "mesh/crypto.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// Internal crypto context
struct mesh_crypto_context {
    // Context data if needed
};

// Crypto context management
mesh_crypto_context_t* mesh_crypto_create_context() {
    mesh_crypto_context_t* ctx = calloc(1, sizeof(mesh_crypto_context_t));
    return ctx;
}

void mesh_crypto_destroy_context(mesh_crypto_context_t* ctx) {
    if (ctx) {
        free(ctx);
    }
}

// Simple AES-GCM implementation (placeholder - needs proper crypto library)
mesh_crypto_error_t mesh_crypto_aes_gcm_encrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* plaintext,
    size_t plaintext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* ciphertext,
    size_t* ciphertext_len) {

    if (!key || !nonce || !plaintext || !ciphertext || !ciphertext_len) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    // TODO: Implement proper AES-GCM encryption
    // For now, just copy plaintext (INSECURE!)
    if (*ciphertext_len < plaintext_len + 16) { // +16 for auth tag
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    memcpy(ciphertext, plaintext, plaintext_len);
    // Add fake auth tag
    memset(ciphertext + plaintext_len, 0, 16);
    *ciphertext_len = plaintext_len + 16;

    return MESH_CRYPTO_SUCCESS;
}

mesh_crypto_error_t mesh_crypto_aes_gcm_decrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* ciphertext,
    size_t ciphertext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* plaintext,
    size_t* plaintext_len) {

    if (!key || !nonce || !ciphertext || !plaintext || !plaintext_len) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    if (ciphertext_len < 16) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    // TODO: Implement proper AES-GCM decryption
    // For now, just copy ciphertext minus auth tag (INSECURE!)
    size_t data_len = ciphertext_len - 16;
    if (*plaintext_len < data_len) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    memcpy(plaintext, ciphertext, data_len);
    *plaintext_len = data_len;

    return MESH_CRYPTO_SUCCESS;
}

// Random number generation (simple implementation)
mesh_crypto_error_t mesh_crypto_random_bytes(uint8_t* buffer, size_t length) {
    if (!buffer || length == 0) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    // TODO: Use proper cryptographically secure random
    // For now, use simple pseudo-random (INSECURE!)
    for (size_t i = 0; i < length; i++) {
        buffer[i] = (uint8_t)(rand() % 256);
    }

    return MESH_CRYPTO_SUCCESS;
}

// Simple SHA-256 implementation (placeholder)
mesh_crypto_error_t mesh_crypto_sha256(
    const uint8_t* data,
    size_t data_len,
    mesh_hash_t hash) {

    if (!data || !hash) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    // TODO: Implement proper SHA-256
    // For now, simple hash (INSECURE!)
    memset(hash, 0, sizeof(mesh_hash_t));
    for (size_t i = 0; i < data_len; i++) {
        hash[i % 32] ^= data[i];
    }

    return MESH_CRYPTO_SUCCESS;
}

mesh_crypto_error_t mesh_crypto_sha512(
    const uint8_t* data,
    size_t data_len,
    uint8_t* hash,
    size_t hash_len) {

    if (!data || !hash || hash_len != 64) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    // TODO: Implement proper SHA-512
    // For now, simple hash (INSECURE!)
    memset(hash, 0, hash_len);
    for (size_t i = 0; i < data_len; i++) {
        hash[i % 64] ^= data[i];
    }

    return MESH_CRYPTO_SUCCESS;
}

// Simple HKDF implementation (placeholder)
mesh_crypto_error_t mesh_crypto_hkdf_sha256(
    const uint8_t* key,
    size_t key_len,
    const uint8_t* salt,
    size_t salt_len,
    const uint8_t* info,
    size_t info_len,
    uint8_t* output,
    size_t output_len) {

    if (!key || !output) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    // TODO: Implement proper HKDF
    // For now, simple key derivation (INSECURE!)
    memset(output, 0, output_len);
    if (key_len > 0) {
        memcpy(output, key, key_len < output_len ? key_len : output_len);
    }

    // Mix in salt and info
    for (size_t i = 0; i < salt_len && i < output_len; i++) {
        output[i] ^= salt[i];
    }
    for (size_t i = 0; i < info_len && i < output_len; i++) {
        output[i] ^= info[i];
    }

    return MESH_CRYPTO_SUCCESS;
}

mesh_crypto_error_t mesh_crypto_derive_mesh_keys(
    const uint8_t* master_key,
    size_t master_key_len,
    const char* node_id,
    mesh_key_t encryption_key,
    mesh_key_t auth_key) {

    if (!master_key || !node_id || !encryption_key || !auth_key) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    size_t node_id_len = strlen(node_id);
    uint8_t context_enc[256];
    uint8_t context_auth[256];

    memcpy(context_enc, "mesh-encryption:", 15);
    memcpy(context_enc + 15, node_id, node_id_len);

    memcpy(context_auth, "mesh-auth:", 10);
    memcpy(context_auth + 10, node_id, node_id_len);

    mesh_crypto_error_t err = mesh_crypto_hkdf_sha256(
        master_key, master_key_len,
        NULL, 0,
        context_enc, 15 + node_id_len,
        encryption_key, 32);

    if (err != MESH_CRYPTO_SUCCESS) {
        return err;
    }

    return mesh_crypto_hkdf_sha256(
        master_key, master_key_len,
        NULL, 0,
        context_auth, 10 + node_id_len,
        auth_key, 32);
}

mesh_crypto_error_t mesh_crypto_derive_session_keys(
    const uint8_t* shared_secret,
    size_t shared_secret_len,
    const char* peer_id1,
    const char* peer_id2,
    mesh_key_t key1,
    mesh_key_t key2) {

    if (!shared_secret || !peer_id1 || !peer_id2 || !key1 || !key2) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    size_t id1_len = strlen(peer_id1);
    size_t id2_len = strlen(peer_id2);

    uint8_t context1[512];
    uint8_t context2[512];

    memcpy(context1, "session-key-1:", 14);
    memcpy(context1 + 14, peer_id1, id1_len);
    context1[14 + id1_len] = ':';
    memcpy(context1 + 15 + id1_len, peer_id2, id2_len);

    memcpy(context2, "session-key-2:", 14);
    memcpy(context2 + 14, peer_id1, id1_len);
    context2[14 + id1_len] = ':';
    memcpy(context2 + 15 + id1_len, peer_id2, id2_len);

    mesh_crypto_error_t err = mesh_crypto_hkdf_sha256(
        shared_secret, shared_secret_len,
        NULL, 0,
        context1, 15 + id1_len + id2_len,
        key1, 32);

    if (err != MESH_CRYPTO_SUCCESS) {
        return err;
    }

    return mesh_crypto_hkdf_sha256(
        shared_secret, shared_secret_len,
        NULL, 0,
        context2, 15 + id1_len + id2_len,
        key2, 32);
}

const char* mesh_crypto_error_string(mesh_crypto_error_t error) {
    switch (error) {
        case MESH_CRYPTO_SUCCESS:
            return "Success";
        case MESH_CRYPTO_ERROR_INVALID_KEY:
            return "Invalid key";
        case MESH_CRYPTO_ERROR_INVALID_DATA:
            return "Invalid data";
        case MESH_CRYPTO_ERROR_ENCRYPTION_FAILED:
            return "Encryption failed";
        case MESH_CRYPTO_ERROR_DECRYPTION_FAILED:
            return "Decryption failed";
        case MESH_CRYPTO_ERROR_SIGNATURE_INVALID:
            return "Invalid signature";
        case MESH_CRYPTO_ERROR_OUT_OF_MEMORY:
            return "Out of memory";
        default:
            return "Unknown error";
    }
}

void mesh_crypto_get_version(int* major, int* minor, int* patch) {
    if (major) *major = 1;
    if (minor) *minor = 0;
    if (patch) *patch = 0;
}
