#include "mesh/crypto.h"
#include <openssl/aes.h>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/sha.h>
#include <cstring>
#include <memory>
#include <iostream>
#include <sstream>

// Internal crypto context
struct mesh_crypto_context {
    // OpenSSL context if needed
};

// C API implementation
extern "C" {

mesh_crypto_context_t* mesh_crypto_create_context() {
    try {
        return new mesh_crypto_context_t();
    } catch (const std::exception& e) {
        std::cerr << "Failed to create crypto context: " << e.what() << std::endl;
        return nullptr;
    }
}

void mesh_crypto_destroy_context(mesh_crypto_context_t* ctx) {
    if (ctx) {
        delete ctx;
    }
}

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

    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) {
        return MESH_CRYPTO_ERROR_OUT_OF_MEMORY;
    }

    if (EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), nullptr, nullptr, nullptr) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_ENCRYPTION_FAILED;
    }

    if (EVP_EncryptInit_ex(ctx, nullptr, nullptr, key, nonce) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_ENCRYPTION_FAILED;
    }

    int len;
    if (aad && aad_len > 0) {
        if (EVP_EncryptUpdate(ctx, nullptr, &len, aad, aad_len) != 1) {
            EVP_CIPHER_CTX_free(ctx);
            return MESH_CRYPTO_ERROR_ENCRYPTION_FAILED;
        }
    }

    if (EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_ENCRYPTION_FAILED;
    }

    size_t current_len = len;

    if (EVP_EncryptFinal_ex(ctx, ciphertext + current_len, &len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_ENCRYPTION_FAILED;
    }

    current_len += len;

    if (EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, ciphertext + current_len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_ENCRYPTION_FAILED;
    }

    current_len += 16;
    *ciphertext_len = current_len;

    EVP_CIPHER_CTX_free(ctx);
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

    if (ciphertext_len < 16) { // At least tag size
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) {
        return MESH_CRYPTO_ERROR_OUT_OF_MEMORY;
    }

    if (EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), nullptr, nullptr, nullptr) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_DECRYPTION_FAILED;
    }

    if (EVP_DecryptInit_ex(ctx, nullptr, nullptr, key, nonce) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_DECRYPTION_FAILED;
    }

    int len;
    if (aad && aad_len > 0) {
        if (EVP_DecryptUpdate(ctx, nullptr, &len, aad, aad_len) != 1) {
            EVP_CIPHER_CTX_free(ctx);
            return MESH_CRYPTO_ERROR_DECRYPTION_FAILED;
        }
    }

    size_t encrypted_len = ciphertext_len - 16;
    if (EVP_DecryptUpdate(ctx, plaintext, &len, ciphertext, encrypted_len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_DECRYPTION_FAILED;
    }

    size_t current_len = len;

    if (EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, (void*)(ciphertext + encrypted_len)) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_DECRYPTION_FAILED;
    }

    if (EVP_DecryptFinal_ex(ctx, plaintext + current_len, &len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return MESH_CRYPTO_ERROR_DECRYPTION_FAILED;
    }

    current_len += len;
    *plaintext_len = current_len;

    EVP_CIPHER_CTX_free(ctx);
    return MESH_CRYPTO_SUCCESS;
}

mesh_crypto_error_t mesh_crypto_random_bytes(uint8_t* buffer, size_t length) {
    if (!buffer || length == 0) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    if (RAND_bytes(buffer, length) != 1) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    return MESH_CRYPTO_SUCCESS;
}

mesh_crypto_error_t mesh_crypto_sha256(
    const uint8_t* data,
    size_t data_len,
    mesh_hash_t hash) {

    if (!data || !hash) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    SHA256(data, data_len, hash);
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

    SHA512(data, data_len, hash);
    return MESH_CRYPTO_SUCCESS;
}

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

    // Simple HKDF implementation using OpenSSL
    uint8_t prk[32];
    if (!HKDF(key, key_len, salt, salt_len, info, info_len, EVP_sha256(), prk, 32)) {
        return MESH_CRYPTO_ERROR_INVALID_DATA;
    }

    // Expand to output length
    if (output_len > 32) {
        // For simplicity, just copy PRK for now
        // TODO: Implement proper HKDF-Expand
        std::memcpy(output, prk, output_len > 32 ? 32 : output_len);
    } else {
        std::memcpy(output, prk, output_len);
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

    std::string context_enc = std::string("mesh-encryption:") + node_id;
    std::string context_auth = std::string("mesh-auth:") + node_id;

    mesh_crypto_error_t err = mesh_crypto_hkdf_sha256(
        master_key, master_key_len,
        nullptr, 0,
        reinterpret_cast<const uint8_t*>(context_enc.c_str()), context_enc.length(),
        encryption_key, 32);

    if (err != MESH_CRYPTO_SUCCESS) {
        return err;
    }

    return mesh_crypto_hkdf_sha256(
        master_key, master_key_len,
        nullptr, 0,
        reinterpret_cast<const uint8_t*>(context_auth.c_str()), context_auth.length(),
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

    std::string context1 = std::string("session-key-1:") + peer_id1 + ":" + peer_id2;
    std::string context2 = std::string("session-key-2:") + peer_id1 + ":" + peer_id2;

    mesh_crypto_error_t err = mesh_crypto_hkdf_sha256(
        shared_secret, shared_secret_len,
        nullptr, 0,
        reinterpret_cast<const uint8_t*>(context1.c_str()), context1.length(),
        key1, 32);

    if (err != MESH_CRYPTO_SUCCESS) {
        return err;
    }

    return mesh_crypto_hkdf_sha256(
        shared_secret, shared_secret_len,
        nullptr, 0,
        reinterpret_cast<const uint8_t*>(context2.c_str()), context2.length(),
        key2, 32);
}

// Placeholder implementations for Ed25519 and ChaCha20
// TODO: Implement with proper crypto libraries

mesh_crypto_error_t mesh_crypto_ed25519_keypair_generate(
    mesh_key_t public_key,
    mesh_key_t private_key) {
    // TODO: Implement Ed25519 key generation
    return mesh_crypto_random_bytes(private_key, 32) == MESH_CRYPTO_SUCCESS &&
           mesh_crypto_random_bytes(public_key, 32) == MESH_CRYPTO_SUCCESS ?
           MESH_CRYPTO_SUCCESS : MESH_CRYPTO_ERROR_INVALID_DATA;
}

mesh_crypto_error_t mesh_crypto_ed25519_sign(
    const mesh_key_t private_key,
    const uint8_t* message,
    size_t message_len,
    mesh_signature_t signature) {
    // TODO: Implement Ed25519 signing
    return MESH_CRYPTO_ERROR_INVALID_DATA;
}

mesh_crypto_error_t mesh_crypto_ed25519_verify(
    const mesh_key_t public_key,
    const uint8_t* message,
    size_t message_len,
    const mesh_signature_t signature) {
    // TODO: Implement Ed25519 verification
    return MESH_CRYPTO_ERROR_INVALID_DATA;
}

mesh_crypto_error_t mesh_crypto_chacha20_poly1305_encrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* plaintext,
    size_t plaintext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* ciphertext,
    size_t* ciphertext_len) {
    // TODO: Implement ChaCha20-Poly1305 encryption
    return MESH_CRYPTO_ERROR_INVALID_DATA;
}

mesh_crypto_error_t mesh_crypto_chacha20_poly1305_decrypt(
    const mesh_key_t key,
    const mesh_nonce_t nonce,
    const uint8_t* ciphertext,
    size_t ciphertext_len,
    const uint8_t* aad,
    size_t aad_len,
    uint8_t* plaintext,
    size_t* plaintext_len) {
    // TODO: Implement ChaCha20-Poly1305 decryption
    return MESH_CRYPTO_ERROR_INVALID_DATA;
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

} // extern "C"

// Helper function for HKDF (simplified implementation)
static bool HKDF(const uint8_t* key, size_t key_len,
                 const uint8_t* salt, size_t salt_len,
                 const uint8_t* info, size_t info_len,
                 const EVP_MD* md,
                 uint8_t* output, size_t output_len) {
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_HKDF, nullptr);
    if (!ctx) {
        return false;
    }

    if (EVP_PKEY_derive_init(ctx) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    if (EVP_PKEY_CTX_hkdf_mode(ctx, EVP_PKEY_HKDEF_MODE_EXTRACT_AND_EXPAND) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    if (EVP_PKEY_CTX_set_hkdf_md(ctx, md) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    if (EVP_PKEY_CTX_set1_hkdf_key(ctx, key, key_len) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    if (salt && EVP_PKEY_CTX_set1_hkdf_salt(ctx, salt, salt_len) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    if (info && EVP_PKEY_CTX_add1_hkdf_info(ctx, info, info_len) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    size_t len = output_len;
    if (EVP_PKEY_derive(ctx, output, &len) <= 0 || len != output_len) {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    EVP_PKEY_CTX_free(ctx);
    return true;
}
