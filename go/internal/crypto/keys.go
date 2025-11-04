package crypto

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
)

// GenerateDeviceID generates a unique device ID
func GenerateDeviceID() string {
	buf := make([]byte, 16)
	rand.Read(buf)
	hash := sha256.Sum256(buf)
	return fmt.Sprintf("mesh_%x", hash[:8])
}

// SignData signs data with private key (simplified for demo)
func SignData(data []byte, privateKey [32]byte) ([]byte, error) {
	// In production, use proper ECDSA or Ed25519 signing
	// For demo, we'll use HMAC-like signature
	hash := sha256.Sum256(append(data, privateKey[:]...))
	return hash[:], nil
}

// VerifySignature verifies signature (simplified for demo)
func VerifySignature(data []byte, signature []byte, publicKey [32]byte) bool {
	// In production, use proper signature verification
	// For demo, we'll verify hash matches
	hash := sha256.Sum256(append(data, publicKey[:]...))
	if len(signature) != len(hash) {
		return false
	}
	for i := range hash {
		if hash[i] != signature[i] {
			return false
		}
	}
	return true
}

// EncodePublicKey encodes public key to base64
func EncodePublicKey(publicKey [32]byte) string {
	return base64.StdEncoding.EncodeToString(publicKey[:])
}

// DecodePublicKey decodes public key from base64
func DecodePublicKey(encoded string) ([32]byte, error) {
	data, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return [32]byte{}, err
	}
	if len(data) != 32 {
		return [32]byte{}, fmt.Errorf("invalid public key length")
	}
	var key [32]byte
	copy(key[:], data)
	return key, nil
}

