import 'package:uuid/uuid.dart';

/// Represents a node in the mesh network
class MeshNode {
  /// Unique identifier for the node
  final String id;
  
  /// Human-readable name of the node
  final String name;
  
  /// Supported transport protocols by this node
  final Set<TransportType> supportedTransports;
  
  /// Additional metadata about the node
  final Map<String, dynamic> metadata;
  
  /// Signal strength (0.0 to 1.0)
  final double signalStrength;
  
  /// Last time this node was seen
  final DateTime lastSeen;
  
  /// First time this node was discovered
  final DateTime? firstSeen;
  
  /// Current status of the connection
  final ConnectionStatus status;
  
  /// Public key for secure communication
  final String? publicKey;
  
  /// Version of the node software
  final String? version;
  
  /// Capabilities of the node
  final Set<NodeCapability> capabilities;
  
  MeshNode({
    String? id,
    required this.name,
    required this.supportedTransports,
    this.metadata = const {},
    this.signalStrength = 0.0,
    DateTime? lastSeen,
    this.firstSeen,
    this.status = ConnectionStatus.disconnected,
    this.publicKey,
    this.version,
    Set<NodeCapability>? capabilities,
  }) : 
    id = id ?? const Uuid().v4(),
    capabilities = capabilities ?? {},
    lastSeen = lastSeen ?? DateTime.now();
  
  /// Creates a copy of this node with the given fields replaced with new values
  MeshNode copyWith({
    String? id,
    String? name,
    Set<TransportType>? supportedTransports,
    Map<String, dynamic>? metadata,
    double? signalStrength,
    DateTime? lastSeen,
    DateTime? firstSeen,
    ConnectionStatus? status,
    String? publicKey,
    String? version,
    Set<NodeCapability>? capabilities,
  }) {
    return MeshNode(
      id: id ?? this.id,
      name: name ?? this.name,
      supportedTransports: supportedTransports ?? this.supportedTransports,
      metadata: metadata ?? Map.from(this.metadata),
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      firstSeen: firstSeen ?? this.firstSeen,
      status: status ?? this.status,
      publicKey: publicKey ?? this.publicKey,
      version: version ?? this.version,
      capabilities: capabilities ?? Set.from(this.capabilities),
    );
  }
  
  /// Creates a MeshNode from JSON
  factory MeshNode.fromJson(Map<String, dynamic> json) {
    return MeshNode(
      id: json['id'],
      name: json['name'] ?? 'Unknown Node',
      supportedTransports: (json['supportedTransports'] as List?)
          ?.map((e) => TransportType.values.firstWhere(
                (type) => type.toString() == 'TransportType.$e',
                orElse: () => TransportType.unknown,
              ))
          .where((e) => e != TransportType.unknown)
          .toSet() ??
          {},
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : {},
      signalStrength: (json['signalStrength'] as num?)?.toDouble() ?? 0.0,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      firstSeen: json['firstSeen'] != null ? DateTime.parse(json['firstSeen']) : null,
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == 'ConnectionStatus.${json['status']}',
        orElse: () => ConnectionStatus.disconnected,
      ),
      publicKey: json['publicKey'],
      version: json['version'],
      capabilities: (json['capabilities'] as List?)
          ?.map((e) => NodeCapability.values.firstWhere(
                (cap) => cap.toString() == 'NodeCapability.$e',
                orElse: () => NodeCapability.unknown,
              ))
          .where((e) => e != NodeCapability.unknown)
          .toSet() ??
          {},
    );
  }
  
  /// Converts this node to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'supportedTransports': supportedTransports
          .map((e) => e.toString().split('.').last)
          .toList(),
      'metadata': Map<String, dynamic>.from(metadata),
      'signalStrength': signalStrength,
      'lastSeen': lastSeen.toIso8601String(),
      'firstSeen': firstSeen?.toIso8601String(),
      'status': status.toString().split('.').last,
      'publicKey': publicKey,
      'version': version,
      'capabilities': capabilities
          .map((e) => e.toString().split('.').last)
          .toList(),
    };
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeshNode &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'MeshNode{id: $id, name: $name, status: $status, transports: $supportedTransports}';
  }
}

/// Types of transport protocols supported by mesh nodes
enum TransportType {
  bluetoothLe,
  wifiDirect,
  wifiAware,
  wifiP2p,
  multicast,
  bleMesh,
  ipv6,
  ipv4,
  usb,
  nfc,
  unknown,
}

/// Connection status of a mesh node
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  authenticated,
  error,
}

/// Capabilities that a node can support
enum NodeCapability {
  messaging,      // Can send/receive messages
  routing,        // Can route messages for other nodes
  storage,        // Can store data for the mesh
  processing,     // Has processing capabilities (AI, etc.)
  gateway,        // Can connect to external networks
  powerEfficient, // Optimized for low power consumption
  highThroughput, // Can handle high data throughput
  locationAware,  // Has location capabilities
  sensorData,     // Can provide sensor data
  unknown,        // Unknown capabilities
}

/// Represents a message in the mesh network
class MeshMessage {
  /// Unique message ID
  final String id;
  
  /// ID of the sender node
  final String senderId;
  
  /// ID of the recipient node (empty for broadcast)
  final String recipientId;
  
  /// Message payload (encrypted or plain text)
  final String payload;
  
  /// Message type (for routing and processing)
  final String messageType;
  
  /// Message timestamp
  final DateTime timestamp;
  
  /// Message priority
  final MessagePriority priority;
  
  /// Whether the message requires reliable delivery
  final bool reliable;
  
  /// Time-to-live (number of hops)
  final int ttl;
  
  /// Additional headers for routing and processing
  final Map<String, String> headers;
  
  MeshMessage({
    String? id,
    required this.senderId,
    required this.recipientId,
    required this.payload,
    this.messageType = 'text',
    DateTime? timestamp,
    this.priority = MessagePriority.normal,
    this.reliable = true,
    this.ttl = 10,
    Map<String, String>? headers,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now(),
    headers = headers ?? {};
  
  /// Creates a MeshMessage from JSON
  factory MeshMessage.fromJson(Map<String, dynamic> json) {
    return MeshMessage(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      payload: json['payload'],
      messageType: json['messageType'] ?? 'text',
      timestamp: DateTime.parse(json['timestamp']),
      priority: MessagePriority.values.firstWhere(
        (e) => e.toString() == 'MessagePriority.${json['priority']}',
        orElse: () => MessagePriority.normal,
      ),
      reliable: json['reliable'] ?? true,
      ttl: json['ttl'] ?? 10,
      headers: json['headers'] is Map 
          ? Map<String, String>.from(json['headers']) 
          : {},
    );
  }
  
  /// Converts this message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'payload': payload,
      'messageType': messageType,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'reliable': reliable,
      'ttl': ttl,
      'headers': headers,
    };
  }
  
  /// Creates a copy of this message with the given fields replaced with new values
  MeshMessage copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? payload,
    String? messageType,
    DateTime? timestamp,
    MessagePriority? priority,
    bool? reliable,
    int? ttl,
    Map<String, String>? headers,
  }) {
    return MeshMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      payload: payload ?? this.payload,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      priority: priority ?? this.priority,
      reliable: reliable ?? this.reliable,
      ttl: ttl ?? this.ttl,
      headers: headers ?? Map.from(this.headers),
    );
  }
  
  @override
  String toString() {
    return 'MeshMessage{id: $id, type: $messageType, from: $senderId, to: $recipientId, ttl: $ttl}';
  }
}

/// Priority levels for message delivery
enum MessagePriority {
  high,    // Critical system messages
  normal,  // Regular messages
  low,     // Background sync, non-urgent data
}

/// Represents an encrypted message in the mesh network
class EncryptedMeshMessage {
  /// Unique message ID
  final String id;
  
  /// Encrypted message data
  final List<int> encryptedData;
  
  /// Initialization vector for decryption
  final List<int> iv;
  
  /// ID of the sender node
  final String senderId;
  
  /// ID of the recipient node (empty for broadcast)
  final String recipientId;
  
  /// Message timestamp
  final DateTime timestamp;
  
  /// Signature for message verification
  final List<int>? signature;
  
  /// Public key of the sender for verification
  final String? senderPublicKey;
  
  EncryptedMeshMessage({
    String? id,
    required this.encryptedData,
    required this.iv,
    required this.senderId,
    required this.recipientId,
    DateTime? timestamp,
    this.signature,
    this.senderPublicKey,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();
  
  /// Creates an EncryptedMeshMessage from JSON
  factory EncryptedMeshMessage.fromJson(Map<String, dynamic> json) {
    return EncryptedMeshMessage(
      id: json['id'],
      encryptedData: List<int>.from(json['encryptedData']),
      iv: List<int>.from(json['iv']),
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      timestamp: DateTime.parse(json['timestamp']),
      signature: json['signature'] != null ? List<int>.from(json['signature']) : null,
      senderPublicKey: json['senderPublicKey'],
    );
  }
  
  /// Converts this encrypted message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encryptedData': encryptedData,
      'iv': iv,
      'senderId': senderId,
      'recipientId': recipientId,
      'timestamp': timestamp.toIso8601String(),
      if (signature != null) 'signature': signature,
      if (senderPublicKey != null) 'senderPublicKey': senderPublicKey,
    };
  }
  
  /// Creates a copy of this message with the given fields replaced with new values
  EncryptedMeshMessage copyWith({
    String? id,
    List<int>? encryptedData,
    List<int>? iv,
    String? senderId,
    String? recipientId,
    DateTime? timestamp,
    List<int>? signature,
    String? senderPublicKey,
  }) {
    return EncryptedMeshMessage(
      id: id ?? this.id,
      encryptedData: encryptedData ?? List.from(this.encryptedData),
      iv: iv ?? List.from(this.iv),
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      timestamp: timestamp ?? this.timestamp,
      signature: signature ?? this.signature,
      senderPublicKey: senderPublicKey ?? this.senderPublicKey,
    );
  }
}
