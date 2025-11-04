import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:uuid/uuid.dart';

/// Enhanced Mesh Service supporting multiple transport protocols and encryption
class EnhancedMeshService {
  static final EnhancedMeshService _instance = EnhancedMeshService._internal();
  factory EnhancedMeshService() => _instance;

  final String _nodeId = const Uuid().v4();
  final Map<String, MeshNode> _peers = {};
  final Map<String, StreamController<MeshMessage>> _messageControllers = {};
  final Map<TransportType, MeshTransport> _transports = {};
  final encrypt.Encrypter _encrypter;

  final StreamController<MeshNode> _onPeerDiscovered =
      StreamController.broadcast();
  final StreamController<MeshNode> _onPeerConnected =
      StreamController.broadcast();
  final StreamController<MeshNode> _onPeerDisconnected =
      StreamController.broadcast();

  Stream<MeshNode> get onPeerDiscovered => _onPeerDiscovered.stream;
  Stream<MeshNode> get onPeerConnected => _onPeerConnected.stream;
  Stream<MeshNode> get onPeerDisconnected => _onPeerDisconnected.stream;

  EnhancedMeshService._internal() : _encrypter = _createEncrypter() {
    _initializeDefaultTransports();
  }

  static encrypt.Encrypter _createEncrypter() {
    // In production, use secure key management
    final key = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16);
    return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  void _initializeDefaultTransports() {
    // Initialize available transports
    _addTransport(BluetoothLETransport());
    _addTransport(WifiDirectTransport());
    _addTransport(MulticastTransport());
  }

  void _addTransport(MeshTransport transport) {
    _transports[transport.type] = transport;

    transport.onPeerDiscovered.listen((peer) {
      _handleDiscoveredPeer(peer);
    });

    transport.onMessageReceived.listen((message) {
      _handleIncomingMessage(message);
    });
  }

  Future<void> start() async {
    await Future.wait(_transports.values.map((t) => t.initialize()));
    await Future.wait(_transports.values.map((t) => t.startDiscovery()));
  }

  Future<void> stop() async {
    await Future.wait(_transports.values.map((t) => t.stopDiscovery()));
    await Future.wait(_transports.values.map((t) => t.dispose()));
  }

  Future<void> sendMessage({
    required String peerId,
    required dynamic payload,
    MessagePriority priority = MessagePriority.normal,
    bool reliable = true,
  }) async {
    final peer = _peers[peerId];
    if (peer == null) throw Exception('Peer not found: $peerId');

    final message = MeshMessage(
      id: const Uuid().v4(),
      senderId: _nodeId,
      recipientId: peerId,
      payload: jsonEncode(payload),
      timestamp: DateTime.now(),
      priority: priority,
      reliable: reliable,
    );

    // Encrypt message
    final encrypted = _encryptMessage(message);

    // Send via best available transport
    final transport = _selectOptimalTransport(peer);
    await transport.sendMessage(peer, encrypted);
  }

  Stream<MeshMessage> messageStream(String peerId) {
    return _messageControllers
        .putIfAbsent(peerId, () => StreamController<MeshMessage>.broadcast())
        .stream;
  }

  MeshTransport _selectOptimalTransport(MeshNode peer) {
    // Simple implementation - prefer the first available transport that both support
    // In a real implementation, this would consider signal strength, bandwidth, etc.
    final availableTransports = _transports.values
        .where((t) => peer.supportedTransports.contains(t.type));

    if (availableTransports.isEmpty) {
      throw Exception('No common transport protocol with peer');
    }

    return availableTransports.first;
  }

  void _handleDiscoveredPeer(MeshNode peer) {
    if (_peers.containsKey(peer.id)) {
      _peers[peer.id] = _peers[peer.id]!.copyWith(
        lastSeen: DateTime.now(),
        signalStrength: peer.signalStrength,
      );
    } else {
      _peers[peer.id] = peer;
      _onPeerDiscovered.add(peer);
    }
  }

  void _handleIncomingMessage(EncryptedMeshMessage encryptedMessage) {
    try {
      final message = _decryptMessage(encryptedMessage);
      _messageControllers[message.senderId]?.add(message);
    } catch (e) {
      // Handle decryption error
      print('Failed to decrypt message: $e');
    }
  }

  EncryptedMeshMessage _encryptMessage(MeshMessage message) {
    final jsonStr = message.toJson();
    final encrypted =
        _encrypter.encrypt(jsonStr, iv: encrypt.IV.fromSecureRandom(16));
    return EncryptedMeshMessage(
      id: message.id,
      encryptedData: encrypted.bytes,
      iv: encrypted.iv,
      senderId: message.senderId,
      recipientId: message.recipientId,
      timestamp: message.timestamp,
    );
  }

  MeshMessage _decryptMessage(EncryptedMeshMessage encryptedMessage) {
    final encrypted = encrypt.Encrypted(encryptedMessage.encryptedData);
    final iv = encrypt.IV(encryptedMessage.iv);
    final jsonStr = _encrypter.decrypt(encrypted, iv: iv);
    return MeshMessage.fromJson(jsonDecode(jsonStr));
  }
}

class MeshNode {
  final String id;
  final String name;
  final Set<TransportType> supportedTransports;
  final Map<String, dynamic> metadata;
  final double signalStrength;
  final DateTime lastSeen;
  final DateTime? firstSeen;

  MeshNode({
    required this.id,
    required this.name,
    required this.supportedTransports,
    this.metadata = const {},
    this.signalStrength = 0.0,
    DateTime? lastSeen,
    this.firstSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  MeshNode copyWith({
    String? name,
    Set<TransportType>? supportedTransports,
    Map<String, dynamic>? metadata,
    double? signalStrength,
    DateTime? lastSeen,
  }) {
    return MeshNode(
      id: id,
      name: name ?? this.name,
      supportedTransports: supportedTransports ?? this.supportedTransports,
      metadata: metadata ?? Map.from(this.metadata),
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      firstSeen: firstSeen,
    );
  }
}

class MeshMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String payload;
  final DateTime timestamp;
  final MessagePriority priority;
  final bool reliable;

  MeshMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.payload,
    DateTime? timestamp,
    this.priority = MessagePriority.normal,
    this.reliable = true,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MeshMessage.fromJson(Map<String, dynamic> json) {
    return MeshMessage(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      payload: json['payload'],
      timestamp: DateTime.parse(json['timestamp']),
      priority: MessagePriority.values.firstWhere(
        (e) => e.toString() == 'MessagePriority.${json['priority']}',
        orElse: () => MessagePriority.normal,
      ),
      reliable: json['reliable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'reliable': reliable,
    };
  }
}

class EncryptedMeshMessage {
  final String id;
  final Uint8List encryptedData;
  final Uint8List iv;
  final String senderId;
  final String recipientId;
  final DateTime timestamp;

  EncryptedMeshMessage({
    required this.id,
    required this.encryptedData,
    required this.iv,
    required this.senderId,
    required this.recipientId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum TransportType {
  bluetoothLe,
  wifiDirect,
  multicast,
  // Add more transport types as needed
}

enum MessagePriority {
  high,
  normal,
  low,
}

abstract class MeshTransport {
  TransportType get type;
  bool get isAvailable;

  Stream<MeshNode> get onPeerDiscovered;
  Stream<EncryptedMeshMessage> get onMessageReceived;

  Future<void> initialize();
  Future<void> startDiscovery();
  Future<void> stopDiscovery();
  Future<void> connect(MeshNode peer);
  Future<void> disconnect(MeshNode peer);
  Future<void> sendMessage(MeshNode peer, EncryptedMeshMessage message);
  Future<void> dispose();
}

// Transport implementations would go here (BluetoothLETransport, WifiDirectTransport, etc.)
// These would be platform-specific implementations using platform channels or plugins

class BluetoothLETransport implements MeshTransport {
  @override
  final TransportType type = TransportType.bluetoothLe;

  @override
  bool get isAvailable => false; // Implementation would check BLE availability

  @override
  Stream<MeshNode> get onPeerDiscovered => const Stream.empty();

  @override
  Stream<EncryptedMeshMessage> get onMessageReceived => const Stream.empty();

  @override
  Future<void> initialize() async {
    // Initialize BLE
  }

  @override
  Future<void> startDiscovery() async {
    // Start BLE scan
  }

  @override
  Future<void> stopDiscovery() async {
    // Stop BLE scan
  }

  @override
  Future<void> connect(MeshNode peer) async {
    // Connect to BLE device
  }

  @override
  Future<void> disconnect(MeshNode peer) async {
    // Disconnect BLE device
  }

  @override
  Future<void> sendMessage(MeshNode peer, EncryptedMeshMessage message) async {
    // Send message over BLE
  }

  @override
  Future<void> dispose() async {
    // Clean up BLE resources
  }
}

class WifiDirectTransport implements MeshTransport {
  @override
  final TransportType type = TransportType.wifiDirect;

  @override
  bool get isAvailable =>
      false; // Implementation would check WiFi Direct availability

  @override
  Stream<MeshNode> get onPeerDiscovered => const Stream.empty();

  @override
  Stream<EncryptedMeshMessage> get onMessageReceived => const Stream.empty();

  @override
  Future<void> initialize() async {
    // Initialize WiFi Direct
  }

  @override
  Future<void> startDiscovery() async {
    // Start WiFi Direct discovery
  }

  @override
  Future<void> stopDiscovery() async {
    // Stop WiFi Direct discovery
  }

  @override
  Future<void> connect(MeshNode peer) async {
    // Connect to WiFi Direct peer
  }

  @override
  Future<void> disconnect(MeshNode peer) async {
    // Disconnect WiFi Direct peer
  }

  @override
  Future<void> sendMessage(MeshNode peer, EncryptedMeshMessage message) async {
    // Send message over WiFi Direct
  }

  @override
  Future<void> dispose() async {
    // Clean up WiFi Direct resources
  }
}

class MulticastTransport implements MeshTransport {
  @override
  final TransportType type = TransportType.multicast;

  @override
  bool get isAvailable => true; // Multicast is generally available

  @override
  Stream<MeshNode> get onPeerDiscovered => const Stream.empty();

  @override
  Stream<EncryptedMeshMessage> get onMessageReceived => const Stream.empty();

  @override
  Future<void> initialize() async {
    // Initialize multicast socket
  }

  @override
  Future<void> startDiscovery() async {
    // Start listening for multicast packets
  }

  @override
  Future<void> stopDiscovery() async {
    // Stop listening for multicast packets
  }

  @override
  Future<void> connect(MeshNode peer) async {
    // No explicit connection needed for multicast
  }

  @override
  Future<void> disconnect(MeshNode peer) async {
    // No explicit disconnection needed for multicast
  }

  @override
  Future<void> sendMessage(MeshNode peer, EncryptedMeshMessage message) async {
    // Send message via multicast
  }

  @override
  Future<void> dispose() async {
    // Clean up multicast resources
  }
}
