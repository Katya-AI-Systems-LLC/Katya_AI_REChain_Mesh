package crypto

import (
	"crypto/rand"
	"crypto/sha256"
	"fmt"

	"golang.org/x/crypto/curve25519"
	"golang.org/x/crypto/hkdf"
)

// KeyPair represents a key pair for mesh handshake
type KeyPair struct {
	PrivateKey [32]byte
	PublicKey  [32]byte
}

// Handshake represents a cryptographic handshake
type Handshake struct {
	KeyPair      *KeyPair
	SharedSecret [32]byte
	SessionKey   []byte
}

// NewKeyPair generates a new key pair
func NewKeyPair() (*KeyPair, error) {
	var privateKey [32]byte
	if _, err := rand.Read(privateKey[:]); err != nil {
		return nil, fmt.Errorf("failed to generate private key: %w", err)
	}

	var publicKey [32]byte
	curve25519.ScalarBaseMult(&publicKey, &privateKey)

	return &KeyPair{
		PrivateKey: privateKey,
		PublicKey:  publicKey,
	}, nil
}

// ComputeSharedSecret computes shared secret from peer's public key
func (kp *KeyPair) ComputeSharedSecret(peerPublicKey [32]byte) ([32]byte, error) {
	var sharedSecret [32]byte
	curve25519.ScalarMult(&sharedSecret, &kp.PrivateKey, &peerPublicKey)
	return sharedSecret, nil
}

// DeriveSessionKey derives session key from shared secret using HKDF
func DeriveSessionKey(sharedSecret [32]byte, salt []byte, info []byte) ([]byte, error) {
	if len(salt) == 0 {
		salt = make([]byte, 32)
		rand.Read(salt)
	}

	if len(info) == 0 {
		info = []byte("katya-mesh-session-key")
	}

	hkdf := hkdf.New(sha256.New, sharedSecret[:], salt, info)
	sessionKey := make([]byte, 32)
	if _, err := hkdf.Read(sessionKey); err != nil {
		return nil, fmt.Errorf("failed to derive session key: %w", err)
	}

	return sessionKey, nil
}

// NewHandshake creates a new handshake instance
func NewHandshake() (*Handshake, error) {
	keyPair, err := NewKeyPair()
	if err != nil {
		return nil, err
	}

	return &Handshake{
		KeyPair:      keyPair,
		SharedSecret: [32]byte{},
		SessionKey:   nil,
	}, nil
}

// Complete completes the handshake with peer's public key
func (h *Handshake) Complete(peerPublicKey [32]byte) error {
	sharedSecret, err := h.KeyPair.ComputeSharedSecret(peerPublicKey)
	if err != nil {
		return err
	}

	h.SharedSecret = sharedSecret

	sessionKey, err := DeriveSessionKey(sharedSecret, nil, nil)
	if err != nil {
		return err
	}

	h.SessionKey = sessionKey
	return nil
}

