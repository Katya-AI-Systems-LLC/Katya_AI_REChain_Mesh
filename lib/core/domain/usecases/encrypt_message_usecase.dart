import 'dart:typed_data';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/crypto_repository.dart';
import 'package:katya_ai_rechain_mesh/core/utils/result.dart';

/// Use case for encrypting messages using GOST or quantum-resistant algorithms
class EncryptMessageUseCase {
  final CryptoRepository _repository;

  const EncryptMessageUseCase(this._repository);

  /// Execute the message encryption operation
  Future<Result<Uint8List>> call({
    required Uint8List data,
    required String recipientPublicKey,
    bool useGOST = true,
    bool useQuantumResistance = false,
  }) async {
    try {
      final encryptedData = await _repository.encryptMessage(
        data: data,
        recipientPublicKey: recipientPublicKey,
        useGOST: useGOST,
        useQuantumResistance: useQuantumResistance,
      );
      return Result.success(encryptedData);
    } catch (e) {
      return Result.failure('Failed to encrypt message: $e');
    }
  }
}
