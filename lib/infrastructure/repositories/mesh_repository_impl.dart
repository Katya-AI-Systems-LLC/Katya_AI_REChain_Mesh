import 'dart:async';
import 'package:katya_ai_rechain_mesh/core/domain/entities/peer.dart';
import 'package:katya_ai_rechain_mesh/core/domain/entities/message.dart';
import 'package:katya_ai_rechain_mesh/core/domain/repositories/mesh_repository.dart';
import 'package:katya_ai_rechain_mesh/core/services/mesh_service.dart';

/// Implementation of MeshRepository using MeshService
class MeshRepositoryImpl implements MeshRepository {
  final MeshService _meshService;

  const MeshRepositoryImpl(this._meshService);

  @override
  Future<void> initialize() => _meshService.initialize();

  @override
  Future<void> startAdvertising() => _meshService.startAdvertising();

  @override
  Future<void> stopAdvertising() => _meshService.stopAdvertising();

  @override
  Stream<List<Peer>> discoverPeers({
    Duration timeout = const Duration(seconds: 10),
    bool includeSignalStrength = true,
  }) => _meshService.discoverPeers(
        timeout: timeout,
        includeSignalStrength: includeSignalStrength,
      );

  @override
  Future<void> stopDiscovery() => _meshService.stopDiscovery();

  @override
  Future<void> connect(String peerId) => _meshService.connect(peerId);

  @override
  Future<void> disconnect(String peerId) => _meshService.disconnect(peerId);

  @override
  Future<void> sendMessage({
    required Message message,
    bool useQuantumChannel = false,
    int maxHops = 5,
  }) => _meshService.sendMessage(
        message: message,
        useQuantumChannel: useQuantumChannel,
        maxHops: maxHops,
      );

  @override
  Future<void> broadcastMessage(Message message) => _meshService.broadcastMessage(message);

  @override
  Stream<Message> get messageStream => _meshService.messageStream;

  @override
  Stream<MeshConnectionState> get connectionStateStream => _meshService.connectionStateStream;

  @override
  List<Peer> get connectedPeers => _meshService.connectedPeers;

  @override
  String get localPeerId => _meshService.localPeerId;

  @override
  Future<void> dispose() => _meshService.dispose();
}
