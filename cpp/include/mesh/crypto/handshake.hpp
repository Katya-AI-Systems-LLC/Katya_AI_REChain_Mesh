#ifndef MESH_CRYPTO_HANDSHAKE_HPP
#define MESH_CRYPTO_HANDSHAKE_HPP

#include <array>
#include <vector>
#include <string>

namespace mesh::crypto {

// X25519 key pair (32 bytes)
using PublicKey = std::array<uint8_t, 32>;
using PrivateKey = std::array<uint8_t, 32>;
using SharedSecret = std::array<uint8_t, 32>;
using SessionKey = std::vector<uint8_t>;

class KeyPair {
public:
    KeyPair();
    ~KeyPair() = default;

    const PublicKey& getPublicKey() const { return public_key_; }
    const PrivateKey& getPrivateKey() const { return private_key_; }

    SharedSecret computeSharedSecret(const PublicKey& peer_public_key) const;

private:
    PrivateKey private_key_;
    PublicKey public_key_;
};

class Handshake {
public:
    Handshake();
    ~Handshake() = default;

    bool complete(const PublicKey& peer_public_key);
    
    const SharedSecret& getSharedSecret() const { return shared_secret_; }
    const SessionKey& getSessionKey() const { return session_key_; }

private:
    KeyPair key_pair_;
    SharedSecret shared_secret_;
    SessionKey session_key_;
};

SessionKey deriveSessionKey(const SharedSecret& shared_secret,
                           const std::vector<uint8_t>& salt = {},
                           const std::vector<uint8_t>& info = {});

std::string generateDeviceID();

} // namespace mesh::crypto

#endif // MESH_CRYPTO_HANDSHAKE_HPP

