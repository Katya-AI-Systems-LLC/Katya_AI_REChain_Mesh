use crate::error::{Error, Result};
use crate::types::NodeId;
use aes_gcm::{Aes256Gcm, Key, Nonce};
use aes_gcm::aead::{Aead, NewAead};
use chacha20poly1305::{ChaCha20Poly1305, Key as ChaChaKey, Nonce as ChaChaNonce};
use chacha20poly1305::aead::{Aead as ChaChaAead, NewAead as ChaChaNewAead};
use ed25519_dalek::{Keypair, PublicKey, SecretKey, Signature, Signer, Verifier};
use hkdf::Hkdf;
use rand::Rng;
use sha2::{Sha256, Sha512, Digest};
use std::convert::TryInto;

/// Cryptographic key sizes
pub const AES_KEY_SIZE: usize = 32;
pub const CHACHA_KEY_SIZE: usize = 32;
pub const NONCE_SIZE: usize = 12;
pub const SIGNATURE_SIZE: usize = 64;

/// AES-GCM encryption/decryption
pub struct AesGcmCrypto {
    key: Key<Aes256Gcm>,
}

impl AesGcmCrypto {
    pub fn new(key: &[u8; AES_KEY_SIZE]) -> Self {
        let key = Key::<Aes256Gcm>::from_slice(key);
        AesGcmCrypto { key: *key }
    }

    pub fn encrypt(&self, plaintext: &[u8], aad: &[u8]) -> Result<Vec<u8>> {
        let cipher = Aes256Gcm::new(&self.key);
        let nonce_bytes: [u8; NONCE_SIZE] = rand::thread_rng().gen();
        let nonce = Nonce::from_slice(&nonce_bytes);

        let ciphertext = cipher.encrypt(nonce, plaintext)
            .map_err(|e| Error::Crypto(format!("AES-GCM encryption failed: {:?}", e)))?;

        let mut result = nonce_bytes.to_vec();
        result.extend_from_slice(&ciphertext);
        Ok(result)
    }

    pub fn decrypt(&self, ciphertext: &[u8], aad: &[u8]) -> Result<Vec<u8>> {
        if ciphertext.len() < NONCE_SIZE {
            return Err(Error::Crypto("Ciphertext too short".to_string()));
        }

        let cipher = Aes256Gcm::new(&self.key);
        let (nonce_bytes, encrypted_data) = ciphertext.split_at(NONCE_SIZE);
        let nonce = Nonce::from_slice(nonce_bytes);

        let plaintext = cipher.decrypt(nonce, encrypted_data)
            .map_err(|e| Error::Crypto(format!("AES-GCM decryption failed: {:?}", e)))?;

        Ok(plaintext)
    }
}

/// ChaCha20-Poly1305 encryption/decryption
pub struct ChaChaCrypto {
    key: ChaChaKey<ChaCha20Poly1305>,
}

impl ChaChaCrypto {
    pub fn new(key: &[u8; CHACHA_KEY_SIZE]) -> Self {
        let key = ChaChaKey::<ChaCha20Poly1305>::from_slice(key);
        ChaChaCrypto { key: *key }
    }

    pub fn encrypt(&self, plaintext: &[u8], aad: &[u8]) -> Result<Vec<u8>> {
        let cipher = ChaCha20Poly1305::new(&self.key);
        let nonce_bytes: [u8; NONCE_SIZE] = rand::thread_rng().gen();
        let nonce = ChaChaNonce::from_slice(&nonce_bytes);

        let ciphertext = cipher.encrypt(nonce, plaintext)
            .map_err(|e| Error::Crypto(format!("ChaCha20-Poly1305 encryption failed: {:?}", e)))?;

        let mut result = nonce_bytes.to_vec();
        result.extend_from_slice(&ciphertext);
        Ok(result)
    }

    pub fn decrypt(&self, ciphertext: &[u8], aad: &[u8]) -> Result<Vec<u8>> {
        if ciphertext.len() < NONCE_SIZE {
            return Err(Error::Crypto("Ciphertext too short".to_string()));
        }

        let cipher = ChaCha20Poly1305::new(&self.key);
        let (nonce_bytes, encrypted_data) = ciphertext.split_at(NONCE_SIZE);
        let nonce = ChaChaNonce::from_slice(nonce_bytes);

        let plaintext = cipher.decrypt(nonce, encrypted_data)
            .map_err(|e| Error::Crypto(format!("ChaCha20-Poly1305 decryption failed: {:?}", e)))?;

        Ok(plaintext)
    }
}

/// Ed25519 digital signatures
pub struct Ed25519Signer {
    keypair: Keypair,
}

impl Ed25519Signer {
    pub fn new() -> Self {
        let mut rng = rand::thread_rng();
        let keypair = Keypair::generate(&mut rng);
        Ed25519Signer { keypair }
    }

    pub fn from_keypair(keypair: Keypair) -> Self {
        Ed25519Signer { keypair }
    }

    pub fn public_key(&self) -> &[u8; 32] {
        self.keypair.public.as_bytes()
    }

    pub fn sign(&self, message: &[u8]) -> Signature {
        self.keypair.sign(message)
    }

    pub fn verify(&self, message: &[u8], signature: &Signature) -> Result<()> {
        self.keypair.public.verify(message, signature)
            .map_err(|e| Error::Crypto(format!("Ed25519 verification failed: {:?}", e)))
    }
}

/// HKDF key derivation
pub fn hkdf_sha256(key: &[u8], salt: &[u8], info: &[u8], output_len: usize) -> Result<Vec<u8>> {
    let hkdf = Hkdf::<Sha256>::new(Some(salt), key);
    let mut output = vec![0u8; output_len];
    hkdf.expand(info, &mut output)
        .map_err(|e| Error::Crypto(format!("HKDF expansion failed: {:?}", e)))?;
    Ok(output)
}

/// SHA-256 hash
pub fn sha256(data: &[u8]) -> [u8; 32] {
    let mut hasher = Sha256::new();
    hasher.update(data);
    hasher.finalize().into()
}

/// SHA-512 hash
pub fn sha512(data: &[u8]) -> [u8; 64] {
    let mut hasher = Sha512::new();
    hasher.update(data);
    hasher.finalize().into()
}

/// Generate random bytes
pub fn random_bytes(len: usize) -> Vec<u8> {
    let mut bytes = vec![0u8; len];
    rand::thread_rng().fill(&mut bytes[..]);
    bytes
}

/// Derive mesh keys from master key and node ID
pub fn derive_mesh_keys(master_key: &[u8], node_id: &NodeId) -> Result<([u8; 32], [u8; 32])> {
    let node_id_hex = node_id.to_hex();
    let context_enc = format!("mesh-encryption:{}", node_id_hex);
    let context_auth = format!("mesh-auth:{}", node_id_hex);

    let enc_key = hkdf_sha256(master_key, &[], context_enc.as_bytes(), 32)?;
    let auth_key = hkdf_sha256(master_key, &[], context_auth.as_bytes(), 32)?;

    let enc_key: [u8; 32] = enc_key.try_into()
        .map_err(|_| Error::Crypto("Invalid key length".to_string()))?;
    let auth_key: [u8; 32] = auth_key.try_into()
        .map_err(|_| Error::Crypto("Invalid key length".to_string()))?;

    Ok((enc_key, auth_key))
}

/// Derive session keys for peer-to-peer communication
pub fn derive_session_keys(shared_secret: &[u8], peer_id1: &NodeId, peer_id2: &NodeId) -> Result<([u8; 32], [u8; 32])> {
    let id1_hex = peer_id1.to_hex();
    let id2_hex = peer_id2.to_hex();
    let context1 = format!("session-key-1:{}:{}", id1_hex, id2_hex);
    let context2 = format!("session-key-2:{}:{}", id1_hex, id2_hex);

    let key1 = hkdf_sha256(shared_secret, &[], context1.as_bytes(), 32)?;
    let key2 = hkdf_sha256(shared_secret, &[], context2.as_bytes(), 32)?;

    let key1: [u8; 32] = key1.try_into()
        .map_err(|_| Error::Crypto("Invalid key length".to_string()))?;
    let key2: [u8; 32] = key2.try_into()
        .map_err(|_| Error::Crypto("Invalid key length".to_string()))?;

    Ok((key1, key2))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_aes_gcm_encrypt_decrypt() {
        let key = [0u8; 32];
        let crypto = AesGcmCrypto::new(&key);
        let plaintext = b"Hello, world!";
        let aad = b"additional data";

        let ciphertext = crypto.encrypt(plaintext, aad).unwrap();
        let decrypted = crypto.decrypt(&ciphertext, aad).unwrap();

        assert_eq!(plaintext, decrypted.as_slice());
    }

    #[test]
    fn test_chacha_encrypt_decrypt() {
        let key = [0u8; 32];
        let crypto = ChaChaCrypto::new(&key);
        let plaintext = b"Hello, world!";
        let aad = b"additional data";

        let ciphertext = crypto.encrypt(plaintext, aad).unwrap();
        let decrypted = crypto.decrypt(&ciphertext, aad).unwrap();

        assert_eq!(plaintext, decrypted.as_slice());
    }

    #[test]
    fn test_ed25519_sign_verify() {
        let signer = Ed25519Signer::new();
        let message = b"Hello, world!";
        let signature = signer.sign(message);

        assert!(signer.verify(message, &signature).is_ok());
        assert!(signer.verify(b"Wrong message", &signature).is_err());
    }

    #[test]
    fn test_sha256() {
        let data = b"Hello, world!";
        let hash = sha256(data);
        assert_eq!(hash.len(), 32);
    }

    #[test]
    fn test_hkdf() {
        let key = b"secret key";
        let salt = b"salt";
        let info = b"info";
        let output = hkdf_sha256(key, salt, info, 32).unwrap();
        assert_eq!(output.len(), 32);
    }
}
