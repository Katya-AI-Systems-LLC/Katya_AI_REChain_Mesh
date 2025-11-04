package crypto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
)

// Encrypt encrypts data using AES-GCM
func Encrypt(plaintext []byte, key []byte) ([]byte, []byte, error) {
	// Create AES cipher
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to create cipher: %w", err)
	}

	// Create GCM
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to create GCM: %w", err)
	}

	// Generate nonce
	nonce := make([]byte, aesGCM.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, nil, fmt.Errorf("failed to generate nonce: %w", err)
	}

	// Encrypt
	ciphertext := aesGCM.Seal(nil, nonce, plaintext, nil)

	return ciphertext, nonce, nil
}

// Decrypt decrypts data using AES-GCM
func Decrypt(ciphertext []byte, nonce []byte, key []byte) ([]byte, error) {
	// Create AES cipher
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("failed to create cipher: %w", err)
	}

	// Create GCM
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("failed to create GCM: %w", err)
	}

	// Check nonce size
	if len(nonce) != aesGCM.NonceSize() {
		return nil, fmt.Errorf("invalid nonce size: %d", len(nonce))
	}

	// Decrypt
	plaintext, err := aesGCM.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt: %w", err)
	}

	return plaintext, nil
}

// EncryptMessage encrypts a message string
func EncryptMessage(message string, sessionKey []byte) ([]byte, []byte, error) {
	return Encrypt([]byte(message), sessionKey)
}

// DecryptMessage decrypts a message string
func DecryptMessage(ciphertext []byte, nonce []byte, sessionKey []byte) (string, error) {
	plaintext, err := Decrypt(ciphertext, nonce, sessionKey)
	if err != nil {
		return "", err
	}
	return string(plaintext), nil
}

