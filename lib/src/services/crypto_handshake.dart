import 'dart:convert';
import 'package:cryptography/cryptography.dart';

/// X25519 ECDH helper and HKDF derivation
class CryptoHandshake {
  static final _x25519 = X25519();
  static final _hkdf = Hkdf(hmac: Hmac.sha256());

  /// Generate an X25519 key pair and return raw public key bytes (32)
  static Future<KeyPair> generateKeyPair() async {
    return await _x25519.newKeyPair();
  }

  /// Extract public key bytes from KeyPair
  static Future<List<int>> extractPublicKey(KeyPair pair) async {
    final pk = await pair.extractPublicKey();
    return pk.bytes;
  }

  /// Derive shared secret given our KeyPair and peer public key bytes
  static Future<List<int>> deriveSharedSecret(
      KeyPair myPair, List<int> peerPublicKey) async {
    final peerPk = SimplePublicKey(peerPublicKey, type: KeyPairType.x25519);
    final shared =
        await _x25519.sharedSecretKey(keyPair: myPair, remotePublicKey: peerPk);
    final secretBytes = await shared.extractBytes();
    return secretBytes;
  }

  /// Derive a symmetric key (32 bytes) from shared secret using HKDF-SHA256
  static Future<List<int>> deriveSymmetricKey(List<int> sharedSecret,
      {List<int>? info}) async {
    final secretKey = SecretKey(sharedSecret);
    final hkdfResult = await _hkdf.deriveKey(
        secretKey: secretKey, info: info ?? [], outputLength: 32);
    final keyBytes = await hkdfResult.extractBytes();
    return keyBytes;
  }

  /// Utility to encode bytes as base64 string
  static String b64(List<int> bytes) => base64Encode(bytes);

  /// Utility to decode base64 to bytes
  static List<int> fromB64(String s) => base64Decode(s);
}
