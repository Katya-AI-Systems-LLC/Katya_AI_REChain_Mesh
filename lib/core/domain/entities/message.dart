import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a message in the mesh network
class Message extends Equatable {
  /// Unique message ID
  final String id;

  /// Sender's peer ID
  final String senderId;

  /// List of recipient peer IDs (empty for broadcast)
  final List<String> recipientIds;

  /// Message type
  final MessageType type;

  /// Message payload (text data)
  final String? text;

  /// Binary data (for files, images, etc.)
  final Uint8List? binaryData;

  /// Timestamp when the message was created
  final DateTime timestamp;

  /// Time-to-live (number of hops)
  final int ttl;

  /// Message priority (0-9, 9 being highest)
  final int priority;

  /// Optional metadata
  final Map<String, dynamic>? metadata;

  /// Whether this message uses quantum encryption
  final bool isQuantumEncrypted;

  /// Whether this message was processed by AI
  final bool isAIProcessed;

  /// Create a new Message
  const Message({
    String? id,
    required this.senderId,
    List<String>? recipientIds,
    required this.type,
    this.text,
    this.binaryData,
    DateTime? timestamp,
    int? ttl,
    int? priority,
    this.metadata,
    this.isQuantumEncrypted = false,
    this.isAIProcessed = false,
  })  : id = id ?? const Uuid().v4(),
        recipientIds = recipientIds ?? const [],
        timestamp = timestamp ?? DateTime.now(),
        ttl = ttl ?? 10,
        priority = (priority ?? 5).clamp(0, 9),
        assert(
          text != null || binaryData != null,
          'Either text or binaryData must be provided',
        ),
        assert(
          priority >= 0 && priority <= 9,
          'Priority must be between 0-9',
        );

  /// Create a text message
  factory Message.text({
    String? id,
    required String senderId,
    List<String>? recipientIds,
    required String text,
    int? ttl,
    int? priority,
    Map<String, dynamic>? metadata,
    bool isQuantumEncrypted = false,
    bool isAIProcessed = false,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      recipientIds: recipientIds,
      type: MessageType.text,
      text: text,
      ttl: ttl,
      priority: priority,
      metadata: metadata,
      isQuantumEncrypted: isQuantumEncrypted,
      isAIProcessed: isAIProcessed,
    );
  }

  /// Create a binary message
  factory Message.binary({
    String? id,
    required String senderId,
    List<String>? recipientIds,
    required Uint8List data,
    MessageType type = MessageType.binary,
    int? ttl,
    int? priority,
    Map<String, dynamic>? metadata,
    bool isQuantumEncrypted = false,
    bool isAIProcessed = false,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      recipientIds: recipientIds,
      type: type,
      binaryData: data,
      ttl: ttl,
      priority: priority,
      metadata: metadata,
      isQuantumEncrypted: isQuantumEncrypted,
      isAIProcessed: isAIProcessed,
    );
  }

  /// Create a Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      recipientIds: List<String>.from(json['recipient_ids'] ?? []),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      text: json['text'] as String?,
      binaryData: json['binary_data'] != null
          ? Uint8List.fromList(List<int>.from(json['binary_data']))
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: json['ttl'] as int? ?? 10,
      priority: json['priority'] as int? ?? 5,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isQuantumEncrypted: json['is_quantum_encrypted'] as bool? ?? false,
      isAIProcessed: json['is_ai_processed'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_ids': recipientIds,
      'type': type.name,
      if (text != null) 'text': text,
      if (binaryData != null) 'binary_data': binaryData!.toList(),
      'timestamp': timestamp.toIso8601String(),
      'ttl': ttl,
      'priority': priority,
      if (metadata != null) 'metadata': metadata,
      'is_quantum_encrypted': isQuantumEncrypted,
      'is_ai_processed': isAIProcessed,
    };
  }

  /// Check if this message is a broadcast
  bool get isBroadcast => recipientIds.isEmpty;

  /// Check if message is expired
  bool get isExpired {
    return DateTime.now().difference(timestamp).inSeconds > ttl * 10; // 10 seconds per hop
  }

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? senderId,
    List<String>? recipientIds,
    MessageType? type,
    String? text,
    Uint8List? binaryData,
    DateTime? timestamp,
    int? ttl,
    int? priority,
    Map<String, dynamic>? metadata,
    bool? isQuantumEncrypted,
    bool? isAIProcessed,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientIds: recipientIds ?? this.recipientIds,
      type: type ?? this.type,
      text: text ?? this.text,
      binaryData: binaryData ?? this.binaryData,
      timestamp: timestamp ?? this.timestamp,
      ttl: ttl ?? this.ttl,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
      isQuantumEncrypted: isQuantumEncrypted ?? this.isQuantumEncrypted,
      isAIProcessed: isAIProcessed ?? this.isAIProcessed,
    );
  }

  /// Create a message with decremented TTL for routing
  Message decrementTTL() {
    return copyWith(ttl: ttl - 1);
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        recipientIds,
        type,
        text,
        binaryData,
        timestamp,
        ttl,
        priority,
        metadata,
        isQuantumEncrypted,
        isAIProcessed,
      ];
}

/// Type of message in the mesh network
enum MessageType {
  text,
  binary,
  command,
  ack,
  error,
  discovery,
  routing,
  chat,
  vote,
  file,
  quantum,
  ai,
}
