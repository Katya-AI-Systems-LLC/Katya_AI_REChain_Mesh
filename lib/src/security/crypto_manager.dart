import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class CryptoManager {
  static final CryptoManager _instance = CryptoManager._internal();
  factory CryptoManager() => _instance;
  static CryptoManager get instance => _instance;
  CryptoManager._internal();

  SimpleKeyPair? _ed25519KeyPair;
  SimplePublicKey? _publicKey;

  Future<void> ensureKeys() async {
    if (_ed25519KeyPair != null) return;
    final algo = Ed25519();
    _ed25519KeyPair = await algo.newKeyPair();
    _publicKey = await _ed25519KeyPair!.extractPublicKey();
  }

  Future<String> getPublicKeyBase64() async {
    await ensureKeys();
    final bytes = _publicKey!.bytes;
    return base64Encode(bytes);
  }

  Future<String> signString(String message) async {
    await ensureKeys();
    final algo = Ed25519();
    final sig = await algo.sign(utf8.encode(message), keyPair: _ed25519KeyPair!);
    return base64Encode(sig.bytes);
  }

  static Future<bool> verifyString({
    required String message,
    required String signatureBase64,
    required String publicKeyBase64,
  }) async {
    try {
      final algo = Ed25519();
      final pk = SimplePublicKey(base64Decode(publicKeyBase64), type: KeyPairType.ed25519);
      final ok = await algo.verify(
        utf8.encode(message),
        signature: Signature(base64Decode(signatureBase64), publicKey: pk),
      );
      return ok;
    } catch (_) {
      return false;
    }
  }
}

