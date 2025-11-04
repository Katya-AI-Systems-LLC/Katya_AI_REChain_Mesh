import 'dart:convert';
import 'dart:math';
import 'crypto_helper.dart';

/// Demo handshake: host generates a random session key and encrypts it using a passphrase-derived key.
/// The host then sends the encrypted JSON payload (ciphertext, nonce, mac) to the peer.
/// Peer uses the same passphrase to derive key and decrypt the session key.
class HandshakeDemo {
  /// Generate a random 32-byte session key
  static List<int> generateSessionKey() {
    final rnd = Random.secure();
    return List<int>.generate(32, (_) => rnd.nextInt(256));
  }

  /// Host: derive passphrase key and encrypt session key, returning JSON string payload
  static Future<String> hostCreateEncryptedSession(String passphrase) async {
    final sessionKey = generateSessionKey();
    final sessionKeyStr = base64Encode(sessionKey);
    final payload = await CryptoHelper.encrypt(
      sessionKeyStr,
      await CryptoHelper.deriveKeyFromPassphrase(passphrase),
    );
    return jsonEncode(payload);
  }

  /// Peer: receive JSON payload and decrypt using passphrase, returning session key bytes
  static Future<List<int>> peerDecryptSession(
    String jsonPayload,
    String passphrase,
  ) async {
    final Map<String, dynamic> map = jsonDecode(jsonPayload);
    final payload = Map<String, String>.from(
      map.map((k, v) => MapEntry(k, v.toString())),
    );
    final sessionKeyB64 = await CryptoHelper.decrypt(
      payload,
      await CryptoHelper.deriveKeyFromPassphrase(passphrase),
    );
    return base64Decode(sessionKeyB64);
  }
}
