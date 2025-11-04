import 'package:equatable/equatable.dart';
import 'base_entity.dart';

/// Represents a peer in the mesh network
class Peer extends BaseEntity {
  /// Display name of the peer
  final String name;
  
  /// Public key of the peer
  final String publicKey;
  
  /// List of supported transport protocols
  final Set<TransportType> supportedTransports;
  
  /// Last known location (optional)
  final GeoLocation? lastKnownLocation;
  
  /// Peer role in the network
  final PeerRole role;
  
  /// Metadata associated with the peer
  final Map<String, dynamic> metadata;

  const Peer({
    required super.id,
    required this.name,
    required this.publicKey,
    required this.supportedTransports,
    required this.role,
    this.lastKnownLocation,
    this.metadata = const {},
    required super.createdAt,
    required super.updatedAt,
  });

  @override
  Peer copyWith({
    String? id,
    String? name,
    String? publicKey,
    Set<TransportType>? supportedTransports,
    GeoLocation? lastKnownLocation,
    PeerRole? role,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Peer(
      id: id ?? this.id,
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      supportedTransports: supportedTransports ?? this.supportedTransports,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      role: role ?? this.role,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        name,
        publicKey,
        supportedTransports,
        lastKnownLocation,
        role,
        metadata,
      ];

  /// Creates a Peer from JSON
  factory Peer.fromJson(Map<String, dynamic> json) {
    return Peer(
      id: json['id'] as String,
      name: json['name'] as String,
      publicKey: json['publicKey'] as String,
      supportedTransports: (json['supportedTransports'] as List)
          .map((e) => TransportType.values.firstWhere(
                (type) => type.toString() == 'TransportType.$e',
                orElse: () => TransportType.unknown,
              ))
          .toSet(),
      role: PeerRole.values.firstWhere(
        (e) => e.toString() == 'PeerRole.${json['role']}',
        orElse: () => PeerRole.peer,
      ),
      lastKnownLocation: json['lastKnownLocation'] != null
          ? GeoLocation.fromJson(
              json['lastKnownLocation'] as Map<String, dynamic>)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the Peer to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'publicKey': publicKey,
      'supportedTransports':
          supportedTransports.map((e) => e.toString().split('.').last).toList(),
      'role': role.toString().split('.').last,
      'lastKnownLocation': lastKnownLocation?.toJson(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Represents a geographic location
class GeoLocation extends Equatable {
  /// Latitude in decimal degrees
  final double latitude;
  
  /// Longitude in decimal degrees
  final double longitude;
  
  /// Altitude in meters (optional)
  final double? altitude;
  
  /// Accuracy of the location in meters (optional)
  final double? accuracy;
  
  /// Timestamp of when the location was recorded
  final DateTime timestamp;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Calculates distance to another location in meters using Haversine formula
  double distanceTo(GeoLocation other) {
    const double earthRadius = 6371000; // meters
    final double lat1 = _toRadians(latitude);
    final double lat2 = _toRadians(other.latitude);
    final double deltaLat = _toRadians(other.latitude - latitude);
    final double deltaLon = _toRadians(other.longitude - longitude);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  /// Creates a GeoLocation from JSON
  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
      accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts the GeoLocation to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        altitude,
        accuracy,
        timestamp,
      ];
}

/// Types of transport protocols supported by peers
enum TransportType {
  bluetooth,
  wifi,
  wifiDirect,
  ble,
  lora,
  lte,
  ethernet,
  unknown,
}

/// Represents the role of a peer in the network
enum PeerRole {
  /// Regular peer with standard permissions
  peer,
  
  /// Super peer that can route messages
  superPeer,
  
  /// Validator node for consensus
  validator,
  
  /// Administrative peer with elevated privileges
  admin,
  
  /// IoT device with limited capabilities
  iotDevice,
  
  /// Emergency services peer with priority routing
  emergencyService,
}
