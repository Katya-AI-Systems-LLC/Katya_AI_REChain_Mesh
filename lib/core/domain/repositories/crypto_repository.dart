import 'dart:typed_data';

/// Abstract interface for cryptographic operations
abstract class CryptoRepository {
  /// Initialize the crypto system
  Future<void> initialize();

  /// Generate a new key pair for the current user
  Future<KeyPair> generateKeyPair({
    bool useGOST = true,
    bool useQuantumResistance = false,
  });

  /// Encrypt data for a specific recipient
  Future<Uint8List> encryptMessage({
    required Uint8List data,
    required String recipientPublicKey,
    bool useGOST = true,
    bool useQuantumResistance = false,
  });

  /// Decrypt data using the current user's private key
  Future<Uint8List> decryptMessage({
    required Uint8List encryptedData,
    required String senderPublicKey,
  });

  /// Sign data with the current user's private key
  Future<Uint8List> signData(Uint8List data);

  /// Verify signature for data
  Future<bool> verifySignature({
    required Uint8List data,
    required Uint8List signature,
    required String publicKey,
  });

  /// Derive shared secret using ECDH
  Future<Uint8List> deriveSharedSecret(String otherPublicKey);

  /// Generate a random nonce/IV
  Uint8List generateNonce();

  /// Hash data using GOST or SHA-256
  Future<Uint8List> hashData(
    Uint8List data, {
    bool useGOST = true,
  });

  /// Get the current user's public key
  String get currentUserPublicKey;

  /// Export key pair for backup
  Future<String> exportKeyPair();

  /// Import key pair from backup
  Future<void> importKeyPair(String exportedKeys);

  /// Clean up resources
  Future<void> dispose();
}

/// Represents a cryptographic key pair
class KeyPair {
  final String publicKey;
  final String privateKey;
  final String algorithm;
  final DateTime createdAt;

  const KeyPair({
    required this.publicKey,
    required this.privateKey,
    required this.algorithm,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from JSON
  factory KeyPair.fromJson(Map<String, dynamic> json) {
    return KeyPair(
      publicKey: json['public_key'] as String,
      privateKey: json['private_key'] as String,
      algorithm: json['algorithm'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'public_key': publicKey,
      'private_key': privateKey,
      'algorithm': algorithm,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  KeyPair copyWith({
    String? publicKey,
    String? privateKey,
    String? algorithm,
    DateTime? createdAt,
  }) {
    return KeyPair(
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      algorithm: algorithm ?? this.algorithm,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Supported cryptographic algorithms
enum CryptoAlgorithm {
  gost34102012, // GOST R 34.10-2012
  gost34112012, // GOST R 34.11-2012
  ecdsaP256,
  ed25519,
  kyber512, // Quantum-resistant KEM
  dilithium2, // Quantum-resistant signature
}
