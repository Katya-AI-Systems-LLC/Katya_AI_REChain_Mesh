import 'package:katya_ai_rechain_mesh/core/domain/entities/peer.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/mesh_repository.dart';
import 'package:katya_ai_rechain_mesh/core/utils/result.dart';

/// Use case for discovering nearby peers in the mesh network
class DiscoverPeersUseCase {
  final MeshRepository _repository;

  const DiscoverPeersUseCase(this._repository);

  /// Execute the peer discovery operation
  Future<Result<List<Peer>>> call({
    Duration timeout = const Duration(seconds: 10),
    bool includeSignalStrength = true,
  }) async {
    try {
      final peers = _repository.discoverPeers(
        timeout: timeout,
        includeSignalStrength: includeSignalStrength,
      );
      return Result.success(peers);
    } catch (e) {
      return Result.failure('Failed to discover peers: $e');
    }
  }
}
