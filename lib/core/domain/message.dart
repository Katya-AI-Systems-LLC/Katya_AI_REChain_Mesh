import 'package:equatable/equatable.dart';

import 'base_entity.dart';
import 'peer.dart';

/// Represents a message in the mesh network
class Message extends BaseEntity {
  /// Sender of the message
  final String senderId;
  
  /// List of recipient peer IDs (empty for broadcast)
  final List<String> recipientIds;
  
  /// Message content
  final MessageContent content;
  
  /// Message type
  final MessageType type;
  
  /// Message priority
  final MessagePriority priority;
  
  /// Optional time-to-live in seconds
  final int? ttl;
  
  /// Optional geofencing constraints
  final GeoFence? geoFence;
  
  /// Message status
  final MessageStatus status;
  
  /// Optional encryption metadata
  final EncryptionMetadata? encryptionMetadata;
  
  /// Optional digital signature
  final String? signature;
  
  /// Optional parent message ID for threading
  final String? parentMessageId;
  
  /// Optional metadata
  final Map<String, dynamic> metadata;

  const Message({
    required super.id,
    required this.senderId,
    this.recipientIds = const [],
    required this.content,
    this.type = MessageType.text,
    this.priority = MessagePriority.normal,
    this.ttl,
    this.geoFence,
    this.status = MessageStatus.created,
    this.encryptionMetadata,
    this.signature,
    this.parentMessageId,
    this.metadata = const {},
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a copy of the message with updated fields
  @override
  Message copyWith({
    String? id,
    String? senderId,
    List<String>? recipientIds,
    MessageContent? content,
    MessageType? type,
    MessagePriority? priority,
    int? ttl,
    GeoFence? geoFence,
    MessageStatus? status,
    EncryptionMetadata? encryptionMetadata,
    String? signature,
    String? parentMessageId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientIds: recipientIds ?? this.recipientIds,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      ttl: ttl ?? this.ttl,
      geoFence: geoFence ?? this.geoFence,
      status: status ?? this.status,
      encryptionMetadata: encryptionMetadata ?? this.encryptionMetadata,
      signature: signature ?? this.signature,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Checks if the message is expired
  bool get isExpired {
    if (ttl == null) return false;
    final expirationTime = createdAt.add(Duration(seconds: ttl!));
    return DateTime.now().isAfter(expirationTime);
  }

  /// Checks if the message is a broadcast
  bool get isBroadcast => recipientIds.isEmpty;

  /// Checks if the message is encrypted
  bool get isEncrypted => encryptionMetadata != null;

  /// Checks if the message is signed
  bool get isSigned => signature != null;

  @override
  List<Object?> get props => [
        ...super.props,
        senderId,
        recipientIds,
        content,
        type,
        priority,
        ttl,
        geoFence,
        status,
        encryptionMetadata,
        signature,
        parentMessageId,
        metadata,
      ];

  /// Creates a Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientIds: (json['recipientIds'] as List).cast<String>(),
      content: MessageContent.fromJson(
          json['content'] as Map<String, dynamic>),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      priority: MessagePriority.values.firstWhere(
        (e) => e.toString() == 'MessagePriority.${json['priority']}',
        orElse: () => MessagePriority.normal,
      ),
      ttl: json['ttl'] as int?,
      geoFence: json['geoFence'] != null
          ? GeoFence.fromJson(json['geoFence'] as Map<String, dynamic>)
          : null,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.created,
      ),
      encryptionMetadata: json['encryptionMetadata'] != null
          ? EncryptionMetadata.fromJson(
              json['encryptionMetadata'] as Map<String, dynamic>)
          : null,
      signature: json['signature'] as String?,
      parentMessageId: json['parentMessageId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientIds': recipientIds,
      'content': content.toJson(),
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      if (ttl != null) 'ttl': ttl,
      if (geoFence != null) 'geoFence': geoFence!.toJson(),
      'status': status.toString().split('.').last,
      if (encryptionMetadata != null)
        'encryptionMetadata': encryptionMetadata!.toJson(),
      if (signature != null) 'signature': signature,
      if (parentMessageId != null) 'parentMessageId': parentMessageId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Represents the content of a message
class MessageContent extends Equatable {
  /// The actual content (text, binary data, etc.)
  final dynamic data;
  
  /// MIME type of the content
  final String mimeType;
  
  /// Optional size in bytes
  final int? size;
  
  /// Optional checksum for data integrity
  final String? checksum;
  
  /// Optional compression information
  final CompressionInfo? compression;

  const MessageContent({
    required this.data,
    required this.mimeType,
    this.size,
    this.checksum,
    this.compression,
  });

  /// Creates a text message content
  factory MessageContent.text(String text) {
    return MessageContent(
      data: text,
      mimeType: 'text/plain',
      size: text.length * 2, // Approximate size in bytes (UTF-16)
    );
  }

  /// Creates a JSON message content
  factory MessageContent.json(Map<String, dynamic> json) {
    return MessageContent(
      data: json,
      mimeType: 'application/json',
      size: json.toString().length * 2, // Approximate size in bytes
    );
  }

  /// Creates a binary message content
  factory MessageContent.binary(
    List<int> bytes, {
    String mimeType = 'application/octet-stream',
  }) {
    return MessageContent(
      data: bytes,
      mimeType: mimeType,
      size: bytes.length,
    );
  }

  /// Checks if the content is text
  bool get isText => mimeType.startsWith('text/') || mimeType == 'application/json';

  /// Gets the content as text
  String? get asText => isText ? data.toString() : null;

  /// Gets the content as JSON
  Map<String, dynamic>? get asJson =>
      mimeType == 'application/json' ? Map<String, dynamic>.from(data) : null;

  /// Gets the content as binary
  List<int>? get asBinary => data is List<int> ? data as List<int> : null;

  @override
  List<Object?> get props => [data, mimeType, size, checksum, compression];

  /// Creates a MessageContent from JSON
  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      data: json['data'],
      mimeType: json['mimeType'] as String,
      size: json['size'] as int?,
      checksum: json['checksum'] as String?,
      compression: json['compression'] != null
          ? CompressionInfo.fromJson(
              json['compression'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the MessageContent to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'mimeType': mimeType,
      if (size != null) 'size': size,
      if (checksum != null) 'checksum': checksum,
      if (compression != null) 'compression': compression!.toJson(),
    };
  }
}

/// Represents compression information for message content
class CompressionInfo extends Equatable {
  /// Compression algorithm used
  final String algorithm;
  
  /// Original size before compression
  final int originalSize;
  
  /// Compression level (0-9, where 0 is no compression and 9 is maximum)
  final int level;

  const CompressionInfo({
    required this.algorithm,
    required this.originalSize,
    this.level = 6,
  });

  /// Compression ratio (0-1, where 1 is no compression)
  double get ratio =>
      originalSize > 0 ? compressedSize / originalSize : 1.0;

  /// Size after compression
  int get compressedSize => originalSize; // This would be updated during compression

  @override
  List<Object?> get props => [algorithm, originalSize, level];

  /// Creates a CompressionInfo from JSON
  factory CompressionInfo.fromJson(Map<String, dynamic> json) {
    return CompressionInfo(
      algorithm: json['algorithm'] as String,
      originalSize: json['originalSize'] as int,
      level: json['level'] as int? ?? 6,
    );
  }

  /// Converts the CompressionInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'algorithm': algorithm,
      'originalSize': originalSize,
      'level': level,
    };
  }
}

/// Represents a geofence for message routing
class GeoFence extends Equatable {
  /// Center point of the geofence
  final GeoLocation center;
  
  /// Radius in meters
  final double radiusMeters;
  
  /// Optional expiration time for the geofence
  final DateTime? expiresAt;

  const GeoFence({
    required this.center,
    required this.radiusMeters,
    this.expiresAt,
  });

  /// Checks if a location is inside the geofence
  bool contains(GeoLocation location) {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    return center.distanceTo(location) <= radiusMeters;
  }

  @override
  List<Object?> get props => [center, radiusMeters, expiresAt];

  /// Creates a GeoFence from JSON
  factory GeoFence.fromJson(Map<String, dynamic> json) {
    return GeoFence(
      center: GeoLocation.fromJson(json['center'] as Map<String, dynamic>),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  /// Converts the GeoFence to JSON
  Map<String, dynamic> toJson() {
    return {
      'center': center.toJson(),
      'radiusMeters': radiusMeters,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }
}

/// Represents encryption metadata for a message
class EncryptionMetadata extends Equatable {
  /// Encryption algorithm used
  final String algorithm;
  
  /// Initialization vector or nonce
  final String iv;
  
  /// Key ID or reference for decryption
  final String keyId;
  
  /// Additional authentication data (AAD)
  final String? aad;
  
  /// Authentication tag
  final String? tag;

  const EncryptionMetadata({
    required this.algorithm,
    required this.iv,
    required this.keyId,
    this.aad,
    this.tag,
  });

  @override
  List<Object?> get props => [algorithm, iv, keyId, aad, tag];

  /// Creates an EncryptionMetadata from JSON
  factory EncryptionMetadata.fromJson(Map<String, dynamic> json) {
    return EncryptionMetadata(
      algorithm: json['algorithm'] as String,
      iv: json['iv'] as String,
      keyId: json['keyId'] as String,
      aad: json['aad'] as String?,
      tag: json['tag'] as String?,
    );
  }

  /// Converts the EncryptionMetadata to JSON
  Map<String, dynamic> toJson() {
    return {
      'algorithm': algorithm,
      'iv': iv,
      'keyId': keyId,
      if (aad != null) 'aad': aad,
      if (tag != null) 'tag': tag,
    };
  }
}

/// Types of messages in the network
enum MessageType {
  /// Standard text message
  text,
  
  /// Binary data (files, images, etc.)
  binary,
  
  /// Command or control message
  command,
  
  /// System notification
  system,
  
  /// Presence update
  presence,
  
  /// Emergency alert
  emergency,
  
  /// IoT device data
  iotData,
  
  /// Custom message type
  custom,
}

/// Priority levels for message delivery
enum MessagePriority {
  /// Lowest priority (best effort)
  low,
  
  /// Normal priority (default)
  normal,
  
  /// High priority (expedited delivery)
  high,
  
  /// Critical priority (immediate delivery)
  critical,
  
  /// Emergency priority (bypass all queues)
  emergency,
}

/// Status of a message in its lifecycle
enum MessageStatus {
  /// Message has been created but not yet sent
  created,
  
  /// Message is queued for sending
  queued,
  
  /// Message is being sent
  sending,
  
  /// Message has been sent but not yet acknowledged
  sent,
  
  /// Message has been delivered to the recipient
  delivered,
  
  /// Message has been read by the recipient
  read,
  
  /// Message delivery failed
  failed,
  
  /// Message has expired (TTL reached)
  expired,
  
  /// Message is being processed
  processing,
  
  /// Message has been processed successfully
  processed,
}
