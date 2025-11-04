import 'dart:async';

import '../mesh_node.dart';

/// Abstract base class for all mesh transport protocols
abstract class MeshTransport {
  /// Type of this transport
  TransportType get type;
  
  /// Whether this transport is currently available
  bool get isAvailable;
  
  /// Whether this transport is currently active
  bool get isActive;
  
  /// Maximum message size this transport can handle
  int get maxMessageSize;
  
  /// Event stream for discovered peers
  Stream<MeshNode> get onPeerDiscovered;
  
  /// Event stream for lost peers
  Stream<MeshNode> get onPeerLost;
  
  /// Event stream for received messages
  Stream<EncryptedMeshMessage> get onMessageReceived;
  
  /// Event stream for connection status changes
  Stream<MapEntry<String, ConnectionStatus>> get onConnectionStatusChanged;
  
  /// Initialize the transport
  Future<void> initialize();
  
  /// Start discovery of other nodes
  Future<void> startDiscovery();
  
  /// Stop discovery of other nodes
  Future<void> stopDiscovery();
  
  /// Connect to a peer
  Future<void> connect(MeshNode peer);
  
  /// Disconnect from a peer
  Future<void> disconnect(MeshNode peer);
  
  /// Send a message to a peer
  Future<void> sendMessage(MeshNode peer, EncryptedMeshMessage message);
  
  /// Get the current connection status for a peer
  ConnectionStatus getConnectionStatus(String nodeId);
  
  /// Clean up resources
  Future<void> dispose();
}

/// Base class for transport implementations
abstract class BaseTransport implements MeshTransport {
  final _peerDiscoveredController = StreamController<MeshNode>.broadcast();
  final _peerLostController = StreamController<MeshNode>.broadcast();
  final _messageReceivedController = StreamController<EncryptedMeshMessage>.broadcast();
  final _connectionStatusController = StreamController<MapEntry<String, ConnectionStatus>>.broadcast();
  
  final Map<String, ConnectionStatus> _connectionStatus = {};
  
  @override
  Stream<MeshNode> get onPeerDiscovered => _peerDiscoveredController.stream;
  
  @override
  Stream<MeshNode> get onPeerLost => _peerLostController.stream;
  
  @override
  Stream<EncryptedMeshMessage> get onMessageReceived => _messageReceivedController.stream;
  
  @override
  Stream<MapEntry<String, ConnectionStatus>> get onConnectionStatusChanged => _connectionStatusController.stream;
  
  @override
  bool get isActive => _isActive;
  bool _isActive = false;
  
  @override
  ConnectionStatus getConnectionStatus(String nodeId) => _connectionStatus[nodeId] ?? ConnectionStatus.disconnected;
  
  /// Update the connection status for a node
  void updateConnectionStatus(String nodeId, ConnectionStatus status) {
    if (_connectionStatus[nodeId] != status) {
      _connectionStatus[nodeId] = status;
      _connectionStatusController.add(MapEntry(nodeId, status));
    }
  }
  
  /// Notify that a peer was discovered
  void notifyPeerDiscovered(MeshNode peer) {
    _peerDiscoveredController.add(peer);
  }
  
  /// Notify that a peer was lost
  void notifyPeerLost(MeshNode peer) {
    _peerLostController.add(peer);
  }
  
  /// Notify that a message was received
  void notifyMessageReceived(EncryptedMeshMessage message) {
    _messageReceivedController.add(message);
  }
  
  @override
  Future<void> dispose() async {
    await _peerDiscoveredController.close();
    await _peerLostController.close();
    await _messageReceivedController.close();
    await _connectionStatusController.close();
    _connectionStatus.clear();
    _isActive = false;
  }
  
  @override
  String toString() => '${runtimeType.toString()}(type: $type, isAvailable: $isAvailable, isActive: $isActive)';
}
