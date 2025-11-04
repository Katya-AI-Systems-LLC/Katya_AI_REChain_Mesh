import 'package:equatable/equatable.dart';

/// Represents a peer in the mesh network
class Peer extends Equatable {
  /// Unique identifier for the peer
  final String id;

  /// Display name of the peer
  final String name;

  /// Device type (phone, tablet, laptop, etc.)
  final String deviceType;

  /// Signal strength (0-100)
  final int signalStrength;

  /// Last seen timestamp
  final DateTime lastSeen;

  /// Supported protocols by this peer
  final List<String> supportedProtocols;

  /// Whether this peer supports quantum channels
  final bool supportsQuantum;

  /// Whether this peer supports AI processing
  final bool supportsAI;

  /// Geographic location (optional)
  final PeerLocation? location;

  /// Create a new Peer instance
  const Peer({
    required this.id,
    required this.name,
    this.deviceType = 'unknown',
    this.signalStrength = 0,
    DateTime? lastSeen,
    this.supportedProtocols = const [],
    this.supportsQuantum = false,
    this.supportsAI = false,
    this.location,
  }) : lastSeen = lastSeen ?? DateTime.now();

  /// Create a Peer from JSON
  factory Peer.fromJson(Map<String, dynamic> json) {
    return Peer(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceType: json['device_type'] as String? ?? 'unknown',
      signalStrength: json['signal_strength'] as int? ?? 0,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      supportedProtocols: List<String>.from(json['supported_protocols'] ?? []),
      supportsQuantum: json['supports_quantum'] as bool? ?? false,
      supportsAI: json['supports_ai'] as bool? ?? false,
      location: json['location'] != null
          ? PeerLocation.fromJson(json['location'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'device_type': deviceType,
      'signal_strength': signalStrength,
      'last_seen': lastSeen.toIso8601String(),
      'supported_protocols': supportedProtocols,
      'supports_quantum': supportsQuantum,
      'supports_ai': supportsAI,
      if (location != null) 'location': location!.toJson(),
    };
  }

  /// Create a copy with updated fields
  Peer copyWith({
    String? id,
    String? name,
    String? deviceType,
    int? signalStrength,
    DateTime? lastSeen,
    List<String>? supportedProtocols,
    bool? supportsQuantum,
    bool? supportsAI,
    PeerLocation? location,
  }) {
    return Peer(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      supportedProtocols: supportedProtocols ?? this.supportedProtocols,
      supportsQuantum: supportsQuantum ?? this.supportsQuantum,
      supportsAI: supportsAI ?? this.supportsAI,
      location: location ?? this.location,
    );
  }

  /// Check if peer is online (seen within last 30 seconds)
  bool get isOnline {
    return DateTime.now().difference(lastSeen).inSeconds < 30;
  }

  /// Get signal strength category
  SignalStrengthCategory get signalCategory {
    if (signalStrength >= 80) return SignalStrengthCategory.excellent;
    if (signalStrength >= 60) return SignalStrengthCategory.good;
    if (signalStrength >= 40) return SignalStrengthCategory.fair;
    if (signalStrength >= 20) return SignalStrengthCategory.poor;
    return SignalStrengthCategory.none;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        deviceType,
        signalStrength,
        lastSeen,
        supportedProtocols,
        supportsQuantum,
        supportsAI,
        location,
      ];
}

/// Geographic location of a peer
class PeerLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const PeerLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  factory PeerLocation.fromJson(Map<String, dynamic> json) {
    return PeerLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

/// Signal strength categories
enum SignalStrengthCategory {
  none,
  poor,
  fair,
  good,
  excellent,
}
