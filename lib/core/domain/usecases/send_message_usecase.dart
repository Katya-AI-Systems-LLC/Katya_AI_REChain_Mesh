import 'package:katya_ai_rechain_mesh/core/domain/entities/message.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/mesh_repository.dart';
import 'package:katya_ai_rechain_mesh/core/utils/result.dart';

/// Use case for sending messages through the mesh network
class SendMessageUseCase {
  final MeshRepository _repository;

  const SendMessageUseCase(this._repository);

  /// Execute the send message operation
  Future<Result<void>> call({
    required Message message,
    bool useQuantumChannel = false,
    int maxHops = 5,
  }) async {
    try {
      await _repository.sendMessage(
        message: message,
        useQuantumChannel: useQuantumChannel,
        maxHops: maxHops,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to send message: $e');
    }
  }
}
