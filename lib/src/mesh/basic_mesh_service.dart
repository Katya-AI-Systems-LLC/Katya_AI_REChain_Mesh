import 'dart:async';
import 'dart:math';

/// A basic implementation of a mesh network service
class BasicMeshService {
  static final BasicMeshService _instance = BasicMeshService._internal();
  
  /// Singleton instance
  static BasicMeshService get instance => _instance;
  
  /// Node ID for this instance
  final String nodeId = _generateNodeId();
  
  /// Map of connected peers
  final Map<String, MeshNode> _peers = {};
  
  /// Stream controller for peer discovery events
  final StreamController<MeshNode> _peerDiscoveredController = StreamController<MeshNode>.broadcast();
  
  /// Stream controller for message events
  final StreamController<MeshMessage> _messageController = StreamController<MeshMessage>.broadcast();
  
  /// Whether the service is currently active
  bool _isActive = false;
  
  /// Timer for simulating peer discovery (for demo purposes)
  Timer? _discoveryTimer;
  
  /// Private constructor for singleton
  BasicMeshService._internal();
  
  /// Whether the service is currently active
  bool get isActive => _isActive;
  
  /// Stream of peer discovery events
  Stream<MeshNode> get onPeerDiscovered => _peerDiscoveredController.stream;
  
  /// Stream of incoming messages
  Stream<MeshMessage> get onMessageReceived => _messageController.stream;
  
  /// List of currently connected peers
  List<MeshNode> get connectedPeers => _peers.values.toList();
  
  /// Start the mesh service
  Future<void> start() async {
    if (_isActive) return;
    
    _isActive = true;
    
    // Simulate peer discovery (in a real implementation, this would use actual network discovery)
    _discoveryTimer = Timer.periodic(const Duration(seconds: 5), _simulatePeerDiscovery);
    
    print('Mesh service started with node ID: $nodeId');
  }
  
  /// Stop the mesh service
  Future<void> stop() async {
    if (!_isActive) return;
    
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    _isActive = false;
    _peers.clear();
    
    print('Mesh service stopped');
  }
  
  /// Send a message to a specific peer
  Future<bool> sendMessage(String peerId, String message, {MessagePriority priority = MessagePriority.normal}) async {
    if (!_isActive) return false;
    
    final peer = _peers[peerId];
    if (peer == null) return false;
    
    // In a real implementation, this would send the message over the network
    print('Sending message to ${peer.id}: $message');
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(400)));
    
    return true;
  }
  
  /// Broadcast a message to all connected peers
  Future<void> broadcast(String message, {MessagePriority priority = MessagePriority.normal}) async {
    if (!_isActive) return;
    
    print('Broadcasting message to ${_peers.length} peers: $message');
    
    // In a real implementation, this would broadcast the message to all connected peers
    for (final peer in _peers.values) {
      await sendMessage(peer.id, message, priority: priority);
    }
  }
  
  /// Simulate discovering a new peer (for demo purposes)
  void _simulatePeerDiscovery(Timer timer) {
    if (!_isActive) return;
    
    // Only simulate discovery if we have few peers (for demo purposes)
    if (_peers.length >= 5) return;
    
    final random = Random();
    final nodeTypes = ['mobile', 'desktop', 'iot', 'server'];
    
    final newNode = MeshNode(
      id: 'node-${random.nextInt(1000)}',
      name: 'Node ${_peers.length + 1}',
      type: nodeTypes[random.nextInt(nodeTypes.length)],
      lastSeen: DateTime.now(),
      signalStrength: 0.5 + random.nextDouble() * 0.5, // 0.5 to 1.0
    );
    
    if (!_peers.containsKey(newNode.id)) {
      _peers[newNode.id] = newNode;
      _peerDiscoveredController.add(newNode);
      print('Discovered new peer: ${newNode.name} (${newNode.id})');
    }
  }
  
  /// Generate a random node ID
  static String _generateNodeId() {
    final random = Random();
    final values = List<int>.generate(8, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }
  
  /// Clean up resources
  void dispose() {
    stop();
    _peerDiscoveredController.close();
    _messageController.close();
  }
}

/// Represents a node in the mesh network
class MeshNode {
  /// Unique identifier for the node
  final String id;
  
  /// Human-readable name of the node
  final String name;
  
  /// Type of node (e.g., 'mobile', 'desktop', 'iot')
  final String type;
  
  /// When this node was last seen
  final DateTime lastSeen;
  
  /// Signal strength (0.0 to 1.0)
  final double signalStrength;
  
  /// Additional metadata
  final Map<String, dynamic> metadata;
  
  MeshNode({
    required this.id,
    required this.name,
    required this.type,
    required this.lastSeen,
    this.signalStrength = 1.0,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};
  
  /// Create a MeshNode from JSON
  factory MeshNode.fromJson(Map<String, dynamic> json) {
    return MeshNode(
      id: json['id'],
      name: json['name'] ?? 'Unknown Node',
      type: json['type'] ?? 'unknown',
      lastSeen: DateTime.parse(json['lastSeen']),
      signalStrength: (json['signalStrength'] as num?)?.toDouble() ?? 1.0,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : {},
    );
  }
  
  /// Convert this node to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'lastSeen': lastSeen.toIso8601String(),
      'signalStrength': signalStrength,
      'metadata': Map<String, dynamic>.from(metadata),
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
    return 'MeshNode{id: $id, name: $name, type: $type, signal: ${(signalStrength * 100).toStringAsFixed(0)}%}';
  }
}

/// Represents a message in the mesh network
class MeshMessage {
  /// Unique message ID
  final String id;
  
  /// ID of the sender node
  final String senderId;
  
  /// ID of the recipient node (empty for broadcast)
  final String recipientId;
  
  /// Message content
  final String content;
  
  /// Message timestamp
  final DateTime timestamp;
  
  /// Message priority
  final MessagePriority priority;
  
  /// Whether the message was delivered
  bool isDelivered = false;
  
  MeshMessage({
    String? id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    DateTime? timestamp,
    this.priority = MessagePriority.normal,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();
  
  /// Create a MeshMessage from JSON
  factory MeshMessage.fromJson(Map<String, dynamic> json) {
    return MeshMessage(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      priority: MessagePriority.values.firstWhere(
        (e) => e.toString() == 'MessagePriority.${json['priority']}',
        orElse: () => MessagePriority.normal,
      ),
    )..isDelivered = json['isDelivered'] ?? false;
  }
  
  /// Convert this message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'isDelivered': isDelivered,
    };
  }
  
  @override
  String toString() {
    return 'Message{$id from $senderId to $recipientId: ${content.length > 20 ? '${content.substring(0, 20)}...' : content}}';
  }
}

/// Priority levels for message delivery
enum MessagePriority {
  low,      // Best effort delivery
  normal,   // Standard priority
  high,     // High priority (e.g., control messages)
  critical, // Critical priority (e.g., emergency alerts)
}
