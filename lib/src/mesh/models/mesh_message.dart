import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mesh_message.g.dart';

// Helper functions for JSON serialization
Uint8List? _base64Decode(String? value) {
  if (value == null) return null;
  return base64Decode(value);
}

String? _base64Encode(Uint8List? value) {
  if (value == null) return null;
  return base64Encode(value);
}

DateTime _dateTimeFromJson(int timestamp) =>
    DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

int _dateTimeToJson(DateTime time) => time.millisecondsSinceEpoch;

/// Type of message in the mesh network
enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('binary')
  binary,
  @JsonValue('command')
  command,
  @JsonValue('ack')
  ack,
  @JsonValue('error')
  error,
  @JsonValue('discovery')
  discovery,
  @JsonValue('routing')
  routing,
  @JsonValue('chat')
  chat,
  @JsonValue('vote')
  vote,
  @JsonValue('file')
  file,
}

/// Represents a message in the mesh network
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class MeshMessage extends Equatable {
  /// Unique message ID
  @JsonKey(required: true)
  final String id;

  /// Sender's peer ID
  @JsonKey(name: 'sender_id', required: true)
  final String senderId;

  /// List of recipient peer IDs (empty for broadcast)
  @JsonKey(
    name: 'recipient_ids',
    defaultValue: <String>[],
  )
  final List<String> recipientIds;

  /// Message type
  @JsonKey(required: true)
  final MessageType type;

  /// Message payload (text data)
  @JsonKey()
  final String? text;

  /// Binary data (base64 encoded in JSON)
  @JsonKey(
    name: 'binary_data',
    fromJson: _base64Decode,
    toJson: _base64Encode,
  )
  final Uint8List? binaryData;

  /// Timestamp when the message was created
  @JsonKey(
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime timestamp;

  /// Time-to-live (number of hops)
  @JsonKey(defaultValue: 10)
  final int ttl;

  /// Message priority (0-9, 9 being highest)
  @JsonKey(defaultValue: 5)
  final int priority;

  /// Optional metadata
  @JsonKey()
  final Map<String, dynamic>? metadata;

  /// Create a new MeshMessage
  MeshMessage({
    required this.id,
    required this.senderId,
    List<String>? recipientIds,
    required this.type,
    this.text,
    this.binaryData,
    DateTime? timestamp,
    int? ttl,
    int? priority,
    this.metadata,
  })  : recipientIds = recipientIds ?? const [],
        timestamp = timestamp ?? DateTime.now().toUtc(),
        ttl = ttl ?? 10,
        priority = (priority ?? 5).clamp(0, 9),
        assert(
          text != null || binaryData != null,
          'Either text or binaryData must be provided',
        ),
        assert(
          priority == null || (priority >= 0 && priority <= 9),
          'Priority must be between 0-9',
        );

  /// Create a text message
  factory MeshMessage.text({
    required String id,
    required String senderId,
    List<String>? recipientIds,
    required String text,
    int? ttl,
    int? priority,
    Map<String, dynamic>? metadata,
  }) {
    return MeshMessage(
      id: id,
      senderId: senderId,
      recipientIds: recipientIds,
      type: MessageType.text,
      text: text,
      ttl: ttl,
      priority: priority,
      metadata: metadata,
    );
  }

  /// Create a binary message
  factory MeshMessage.binary({
    required String id,
    required String senderId,
    List<String>? recipientIds,
    required Uint8List data,
    int? ttl,
    int? priority,
    Map<String, dynamic>? metadata,
  }) {
    return MeshMessage(
      id: id,
      senderId: senderId,
      recipientIds: recipientIds,
      type: MessageType.binary,
      binaryData: data,
      ttl: ttl,
      priority: priority,
      metadata: metadata,
    );
  }

  /// Create a MeshMessage from JSON string
  factory MeshMessage.fromJsonString(String jsonString) {
    return MeshMessage.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Create a MeshMessage from JSON
  factory MeshMessage.fromJson(Map<String, dynamic> json) =>
      _$MeshMessageFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MeshMessageToJson(this);

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Check if this message is a broadcast
  bool get isBroadcast => recipientIds.isEmpty;

  /// Create a copy with updated fields
  MeshMessage copyWith({
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
  }) {
    return MeshMessage(
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
    );
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
      ];
}
