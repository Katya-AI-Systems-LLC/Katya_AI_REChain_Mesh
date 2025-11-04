import 'dart:convert';
import 'dart:typed_data';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/crypto_repository.dart';
import 'package:katya_ai_rechain_mesh/core/services/crypto_service.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/pointycastle.dart' as pc;

/// Implementation of CryptoRepository using CryptoService and native crypto
class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoService _cryptoService;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  CryptoRepositoryImpl(this._cryptoService);

  @override
  Future<void> initialize() async {
    await _cryptoService.initialize();
    // Initialize AES encrypter with a default key (should be replaced with proper key management)
    final key = encrypt.Key.fromLength(32);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    _iv = encrypt.IV.fromLength(16);
  }

  @override
  Future<KeyPair> generateKeyPair({
    bool useGOST = true,
    bool useQuantumResistance = false,
  }) => _cryptoService.generateKeyPair(
        useGOST: useGOST,
        useQuantumResistance: useQuantumResistance,
      );

  @override
  Future<Uint8List> encryptMessage({
    required Uint8List data,
    required String recipientPublicKey,
    bool useGOST = true,
    bool useQuantumResistance = false,
  }) async {
    if (useGOST) {
      // Use GOST encryption
      return _cryptoService.encryptMessage(
        data: data,
        recipientPublicKey: recipientPublicKey,
        useGOST: true,
        useQuantumResistance: useQuantumResistance,
      );
    } else {
      // Use AES encryption as fallback
      final encrypted = _encrypter.encryptBytes(data, iv: _iv);
      return Uint8List.fromList(encrypted.bytes);
    }
  }

  @override
  Future<Uint8List> decryptMessage({
    required Uint8List encryptedData,
    required String senderPublicKey,
  }) => _cryptoService.decryptMessage(
        encryptedData: encryptedData,
        senderPublicKey: senderPublicKey,
      );

  @override
  Future<Uint8List> signData(Uint8List data) => _cryptoService.signData(data);

  @override
  Future<bool> verifySignature({
    required Uint8List data,
    required Uint8List signature,
    required String publicKey,
  }) => _cryptoService.verifySignature(
        data: data,
        signature: signature,
        publicKey: publicKey,
      );

  @override
  Future<Uint8List> deriveSharedSecret(String otherPublicKey) =>
      _cryptoService.deriveSharedSecret(otherPublicKey);

  @override
  Uint8List generateNonce() => _cryptoService.generateNonce();

  @override
  Future<Uint8List> hashData(Uint8List data, {bool useGOST = true}) =>
      _cryptoService.hashData(data, useGOST: useGOST);

  @override
  String get currentUserPublicKey => _cryptoService.currentUserPublicKey;

  @override
  Future<String> exportKeyPair() => _cryptoService.exportKeyPair();

  @override
  Future<void> importKeyPair(String exportedKeys) =>
      _cryptoService.importKeyPair(exportedKeys);

  @override
  Future<void> dispose() => _cryptoService.dispose();
}
