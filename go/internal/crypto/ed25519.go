package crypto

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/hex"
	"fmt"

	"golang.org/x/crypto/argon2"
)

// Ed25519KeyPair represents an Ed25519 key pair
type Ed25519KeyPair struct {
	PublicKey  []byte
	PrivateKey []byte
}

// GenerateEd25519KeyPair generates a new Ed25519 key pair
func GenerateEd25519KeyPair() (*Ed25519KeyPair, error) {
	publicKey, privateKey, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return nil, fmt.Errorf("failed to generate Ed25519 key pair: %w", err)
	}

	return &Ed25519KeyPair{
		PublicKey:  publicKey,
		PrivateKey: privateKey,
	}, nil
}

// Ed25519Sign signs a message using Ed25519
func Ed25519Sign(privateKey []byte, message []byte) ([]byte, error) {
	if len(privateKey) != ed25519.PrivateKeySize {
		return nil, fmt.Errorf("invalid private key size: expected %d, got %d", ed25519.PrivateKeySize, len(privateKey))
	}

	signature := ed25519.Sign(privateKey, message)
	return signature, nil
}

// Ed25519Verify verifies an Ed25519 signature
func Ed25519Verify(publicKey []byte, message []byte, signature []byte) bool {
	if len(publicKey) != ed25519.PublicKeySize {
		return false
	}

	return ed25519.Verify(publicKey, message, signature)
}

// Ed25519KeyPairFromSeed generates a key pair from a seed using Argon2
func Ed25519KeyPairFromSeed(seed string, salt []byte) (*Ed25519KeyPair, error) {
	// Use Argon2 to derive a 32-byte seed from the string seed
	derivedSeed := argon2.IDKey([]byte(seed), salt, 1, 64*1024, 4, 32)

	privateKey := ed25519.NewKeyFromSeed(derivedSeed)
	publicKey := privateKey.Public().(ed25519.PublicKey)

	return &Ed25519KeyPair{
		PublicKey:  publicKey,
		PrivateKey: privateKey,
	}, nil
}

// Ed25519KeyPairToHex converts key pair to hex strings
func (kp *Ed25519KeyPair) ToHex() (string, string) {
	return hex.EncodeToString(kp.PublicKey), hex.EncodeToString(kp.PrivateKey)
}

// Ed25519KeyPairFromHex creates key pair from hex strings
func Ed25519KeyPairFromHex(publicHex, privateHex string) (*Ed25519KeyPair, error) {
	publicKey, err := hex.DecodeString(publicHex)
	if err != nil {
		return nil, fmt.Errorf("failed to decode public key: %w", err)
	}

	privateKey, err := hex.DecodeString(privateHex)
	if err != nil {
		return nil, fmt.Errorf("failed to decode private key: %w", err)
	}

	if len(publicKey) != ed25519.PublicKeySize || len(privateKey) != ed25519.PrivateKeySize {
		return nil, fmt.Errorf("invalid key sizes")
	}

	return &Ed25519KeyPair{
		PublicKey:  publicKey,
		PrivateKey: privateKey,
	}, nil
}
