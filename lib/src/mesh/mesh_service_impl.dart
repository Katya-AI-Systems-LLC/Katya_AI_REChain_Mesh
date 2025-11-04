import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'mesh_service.dart';
import 'models/mesh_message.dart';
import 'models/peer_info.dart';

/// Implementation of MeshService using a simplified approach without Bluetooth
/// This is a placeholder implementation that can be extended with actual networking
class MeshServiceImpl implements MeshService {
  static const String _serviceUuid = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String _rxCharacteristicUuid = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String _txCharacteristicUuid = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

  final String _localPeerName;
  final String _deviceType;

  final StreamController<MeshMessage> _messageController = StreamController.broadcast();
  final StreamController<MeshConnectionState> _connectionStateController = StreamController.broadcast();

  final Map<String, dynamic> _connectedDevices = {};
  final Map<String, PeerInfo> _discoveredPeers = {};
  final String _localPeerId;

  bool _isAdvertising = false;
  bool _isDiscovering = false;

  /// Create a new MeshService instance
  MeshServiceImpl({
    required String localPeerName,
    String? localPeerId,
    String deviceType = 'mobile',
  })  : _localPeerName = localPeerName,
        _deviceType = deviceType,
        _localPeerId = localPeerId ?? const Uuid().v4();

  @override
  Future<void> initialize() async {
    // Simplified initialization without Bluetooth
    _connectionStateController.add(MeshConnectionState.connected);
  }

  @override
  Future<void> startAdvertising() async {
    if (_isAdvertising) return;

    _isAdvertising = true;
    _connectionStateController.add(MeshConnectionState.advertising);
  }

  @override
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    _isAdvertising = false;
    _connectionStateController.add(MeshConnectionState.connected);
  }

  @override
  Stream<PeerInfo> discoverPeers() async* {
    if (_isDiscovering) {
      for (var peer in _discoveredPeers.values) {
        yield peer;
      }
      return;
    }

    _isDiscovering = true;
    _connectionStateController.add(MeshConnectionState.discovering);

    try {
      // Simulate peer discovery
      await Future.delayed(const Duration(seconds: 2));

      // Add some mock peers for demonstration
      _discoveredPeers['peer1'] = PeerInfo(
        id: 'peer1',
        name: 'Mock Peer 1',
        deviceType: 'mobile',
        signalStrength: 80,
      );

      _discoveredPeers['peer2'] = PeerInfo(
        id: 'peer2',
        name: 'Mock Peer 2',
        deviceType: 'desktop',
        signalStrength: 65,
      );

      for (var peer in _discoveredPeers.values) {
        yield peer;
      }
    } finally {
      _isDiscovering = false;
      _connectionStateController.add(MeshConnectionState.connected);
    }
  }

  @override
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    _isDiscovering = false;
    _connectionStateController.add(MeshConnectionState.connected);
  }

  @override
  Future<void> connect(String peerId) async {
    if (_connectedDevices.containsKey(peerId)) return;

    final device = _discoveredPeers[peerId];
    if (device == null) {
      throw Exception('Peer not found: $peerId');
    }

    try {
      _connectionStateController.add(MeshConnectionState.connecting);

      // Simulate connection
      await Future.delayed(const Duration(seconds: 1));

      _connectedDevices[peerId] = device;
      _connectionStateController.add(MeshConnectionState.connected);
    } catch (e) {
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> disconnect(String peerId) async {
    final device = _connectedDevices[peerId];
    if (device == null) return;

    try {
      // Simulate disconnect
      await Future.delayed(const Duration(milliseconds: 500));
      _connectedDevices.remove(peerId);
    } catch (e) {
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String peerId, MeshMessage message) async {
    if (!_connectedDevices.containsKey(peerId)) {
      throw Exception('Not connected to peer: $peerId');
    }

    try {
      // Simulate sending message
      await Future.delayed(const Duration(milliseconds: 100));

      // For demo purposes, echo the message back as if received
      _messageController.add(message);
    } catch (e) {
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> broadcastMessage(MeshMessage message) async {
    final futures = <Future>[];

    for (final peerId in _connectedDevices.keys) {
      futures.add(sendMessage(peerId, message));
    }

    await Future.wait(futures);
  }

  @override
  Stream<MeshMessage> get messageStream => _messageController.stream;

  @override
  Stream<MeshConnectionState> get connectionStateStream => _connectionStateController.stream;

  @override
  List<PeerInfo> get connectedPeers => _connectedDevices.entries
      .map((entry) => _discoveredPeers[entry.key]!)
      .toList();

  @override
  String get localPeerId => _localPeerId;

  @override
  Future<void> dispose() async {
    await _messageController.close();
    await _connectionStateController.close();
    await stopAdvertising();
    await stopDiscovery();

    _connectedDevices.clear();
  }

  // Helper Methods

  void _handleIncomingMessage(Uint8List data, String senderId) {
    try {
      final messageJson = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      final message = MeshMessage.fromJson(messageJson);

      _messageController.add(message);
    } catch (e) {
      // Handle error
    }
  }

  int _convertRssiToPercentage(int rssi) {
    const minRssi = -100;
    const maxRssi = -30;

    if (rssi >= maxRssi) return 100;
    if (rssi <= minRssi) return 0;

    return ((rssi - minRssi) * 100 / (maxRssi - minRssi)).round();
  }
}
