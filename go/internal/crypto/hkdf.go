package crypto

import (
	"crypto/sha256"
	"crypto/sha512"
	"fmt"
	"hash"

	"golang.org/x/crypto/hkdf"
)

// HKDFExpand expands a key using HKDF
func HKDFExpand(key []byte, salt []byte, info []byte, length int) ([]byte, error) {
	if length <= 0 {
		return nil, fmt.Errorf("invalid length: %d", length)
	}

	hkdf := hkdf.New(sha256.New, key, salt, info)
	result := make([]byte, length)
	if _, err := hkdf.Read(result); err != nil {
		return nil, fmt.Errorf("failed to expand key: %w", err)
	}

	return result, nil
}

// HKDFExpandSHA512 expands a key using HKDF with SHA-512
func HKDFExpandSHA512(key []byte, salt []byte, info []byte, length int) ([]byte, error) {
	if length <= 0 {
		return nil, fmt.Errorf("invalid length: %d", length)
	}

	hkdf := hkdf.New(sha512.New, key, salt, info)
	result := make([]byte, length)
	if _, err := hkdf.Read(result); err != nil {
		return nil, fmt.Errorf("failed to expand key: %w", err)
	}

	return result, nil
}

// HKDFDeriveKey derives a key using HKDF with custom hash function
func HKDFDeriveKey(hashFunc func() hash.Hash, key []byte, salt []byte, info []byte, length int) ([]byte, error) {
	if length <= 0 {
		return nil, fmt.Errorf("invalid length: %d", length)
	}

	hkdf := hkdf.New(hashFunc, key, salt, info)
	result := make([]byte, length)
	if _, err := hkdf.Read(result); err != nil {
		return nil, fmt.Errorf("failed to derive key: %w", err)
	}

	return result, nil
}

// HKDFExtract extracts a pseudorandom key from input keying material
func HKDFExtract(key []byte, salt []byte) []byte {
	return hkdf.Extract(sha256.New, key, salt)
}

// HKDFExtractSHA512 extracts a pseudorandom key using SHA-512
func HKDFExtractSHA512(key []byte, salt []byte) []byte {
	return hkdf.Extract(sha512.New, key, salt)
}

// GenerateMeshKeys generates encryption and authentication keys for mesh networking
func GenerateMeshKeys(masterKey []byte, nodeID string) (encryptionKey []byte, authKey []byte, err error) {
	// Derive encryption key
	encryptionKey, err = HKDFExpand(masterKey, []byte("mesh-encryption"), []byte(nodeID), 32)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to derive encryption key: %w", err)
	}

	// Derive authentication key
	authKey, err = HKDFExpand(masterKey, []byte("mesh-auth"), []byte(nodeID), 32)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to derive auth key: %w", err)
	}

	return encryptionKey, authKey, nil
}

// GenerateSessionKeys generates session keys for peer-to-peer communication
func GenerateSessionKeys(sharedSecret []byte, peerID1, peerID2 string) (key1 []byte, key2 []byte, err error) {
	// Ensure consistent ordering
	var context string
	if peerID1 < peerID2 {
		context = peerID1 + peerID2
	} else {
		context = peerID2 + peerID1
	}

	// Derive key for peer 1
	key1, err = HKDFExpand(sharedSecret, []byte("session-key-1"), []byte(context), 32)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to derive key1: %w", err)
	}

	// Derive key for peer 2
	key2, err = HKDFExpand(sharedSecret, []byte("session-key-2"), []byte(context), 32)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to derive key2: %w", err)
	}

	return key1, key2, nil
}
