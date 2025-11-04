import 'dart:async';

import 'package:katya_ai_rechain_mesh/src/mesh/models/peer_info.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/models/mesh_message.dart';

/// Interface for the mesh networking service
abstract class MeshService {
  /// Initialize the mesh network
  Future<void> initialize();

  /// Start advertising this device on the mesh network
  Future<void> startAdvertising();

  /// Stop advertising this device
  Future<void> stopAdvertising();

  /// Start discovering nearby peers
  Stream<PeerInfo> discoverPeers();

  /// Stop discovering peers
  Future<void> stopDiscovery();

  /// Connect to a peer
  Future<void> connect(String peerId);

  /// Disconnect from a peer
  Future<void> disconnect(String peerId);

  /// Send a message to a specific peer
  Future<void> sendMessage(String peerId, MeshMessage message);

  /// Broadcast a message to all connected peers
  Future<void> broadcastMessage(MeshMessage message);

  /// Stream of received messages
  Stream<MeshMessage> get messageStream;

  /// Stream of connection state changes
  Stream<MeshConnectionState> get connectionStateStream;

  /// Get list of connected peers
  List<PeerInfo> get connectedPeers;

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
