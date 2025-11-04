import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'peer_info.g.dart';

/// Represents a peer in the mesh network
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createToJson: true,
)
class PeerInfo extends Equatable {
  /// Unique identifier for the peer
  @JsonKey(required: true)
  final String id;

  /// Display name of the peer
  @JsonKey(required: true)
  final String name;

  /// Type of device (phone, tablet, etc.)
  @JsonKey(defaultValue: 'unknown')
  final String deviceType;

  /// Signal strength (0-100)
  @JsonKey(defaultValue: 0)
  final int signalStrength;

  /// Last seen timestamp
  @JsonKey(
    name: 'last_seen',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime lastSeen;

  /// Supported protocols by this peer
  @JsonKey(
    name: 'supported_protocols',
    defaultValue: [],
  )
  final List<String> supportedProtocols;

  /// Create a new PeerInfo instance
  PeerInfo({
    required this.id,
    required this.name,
    this.deviceType = 'unknown',
    this.signalStrength = 0,
    DateTime? lastSeen,
    List<String>? supportedProtocols,
  })  : lastSeen = lastSeen ?? DateTime.now().toUtc(),
        supportedProtocols = supportedProtocols ?? const [];

  /// Create a PeerInfo from JSON string
  factory PeerInfo.fromJsonString(String jsonString) {
    return PeerInfo.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Create a PeerInfo from JSON
  factory PeerInfo.fromJson(Map<String, dynamic> json) {
    return _$PeerInfoFromJson(json);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PeerInfoToJson(this);

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Helper methods for JSON serialization
  static DateTime _dateTimeFromJson(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

  static int _dateTimeToJson(DateTime time) => time.millisecondsSinceEpoch;

  /// Create a copy with updated fields
  PeerInfo copyWith({
    String? id,
    String? name,
    String? deviceType,
    int? signalStrength,
    DateTime? lastSeen,
    List<String>? supportedProtocols,
  }) {
    return PeerInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      supportedProtocols: supportedProtocols ?? this.supportedProtocols,
    );
  }

  @override
  List<Object?> get props => [id, name, deviceType, signalStrength, lastSeen];
}
