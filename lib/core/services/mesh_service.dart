import 'dart:async';
import 'package:katya_ai_rechain_mesh/core/domain/entities/peer.dart';
import 'package:katya_ai_rechain_mesh/core/domain/entities/message.dart';

/// Abstract interface for mesh networking service
abstract class MeshService {
  /// Initialize the mesh network
  Future<void> initialize();

  /// Start advertising this device on the mesh network
  Future<void> startAdvertising();

  /// Stop advertising this device
  Future<void> stopAdvertising();

  /// Start discovering nearby peers
  Stream<List<Peer>> discoverPeers({
    Duration timeout = const Duration(seconds: 10),
    bool includeSignalStrength = true,
  });

  /// Stop discovering peers
  Future<void> stopDiscovery();

  /// Connect to a peer
  Future<void> connect(String peerId);

  /// Disconnect from a peer
  Future<void> disconnect(String peerId);

  /// Send a message to a specific peer or broadcast
  Future<void> sendMessage({
    required Message message,
    bool useQuantumChannel = false,
    int maxHops = 5,
  });

  /// Broadcast a message to all connected peers
  Future<void> broadcastMessage(Message message);

  /// Stream of received messages
  Stream<Message> get messageStream;

  /// Stream of connection state changes
  Stream<MeshConnectionState> get connectionStateStream;

  /// Get list of connected peers
  List<Peer> get connectedPeers;

  /// Get the local peer ID
  String get localPeerId;

  /// Clean up resources
  Future<void> dispose();
}

/// Connection state of the mesh network
enum MeshConnectionState {
  disconnected,
  connecting,
  connected,
  error,
  advertising,
  discovering,
}
