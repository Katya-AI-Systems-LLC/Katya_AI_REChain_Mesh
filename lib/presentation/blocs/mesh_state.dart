part of 'mesh_bloc.dart';

/// Status of the mesh network
enum MeshStatus {
  initial,
  initializing,
  initialized,
  error,
}

/// State for the mesh BLoC
class MeshState extends Equatable {
  /// Current status of the mesh network
  final MeshStatus status;

  /// List of discovered peers
  final List<Peer> discoveredPeers;

  /// List of connected peers
  final List<Peer> connectedPeers;

  /// List of received messages
  final List<Message> receivedMessages;

  /// Current connection state
  final MeshConnectionState connectionState;

  /// Local peer ID
  final String? localPeerId;

  /// Whether peer discovery is in progress
  final bool isDiscovering;

  /// Whether connecting to a peer
  final bool isConnecting;

  /// Error message if any
  final String? errorMessage;

  const MeshState({
    this.status = MeshStatus.initial,
    this.discoveredPeers = const [],
    this.connectedPeers = const [],
    this.receivedMessages = const [],
    this.connectionState = MeshConnectionState.disconnected,
    this.localPeerId,
    this.isDiscovering = false,
    this.isConnecting = false,
    this.errorMessage,
  });

  /// Create a copy with updated fields
  MeshState copyWith({
    MeshStatus? status,
    List<Peer>? discoveredPeers,
    List<Peer>? connectedPeers,
    List<Message>? receivedMessages,
    MeshConnectionState? connectionState,
    String? localPeerId,
    bool? isDiscovering,
    bool? isConnecting,
    String? errorMessage,
  }) {
    return MeshState(
      status: status ?? this.status,
      discoveredPeers: discoveredPeers ?? this.discoveredPeers,
      connectedPeers: connectedPeers ?? this.connectedPeers,
      receivedMessages: receivedMessages ?? this.receivedMessages,
      connectionState: connectionState ?? this.connectionState,
      localPeerId: localPeerId ?? this.localPeerId,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isConnecting: isConnecting ?? this.isConnecting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get the number of online peers
  int get onlinePeersCount => discoveredPeers.where((peer) => peer.isOnline).length;

  /// Get the number of connected peers
  int get connectedPeersCount => connectedPeers.length;

  /// Get the total number of messages received
  int get totalMessagesCount => receivedMessages.length;

  /// Check if the mesh is connected
  bool get isConnected => connectionState == MeshConnectionState.connected;

  /// Check if there are any errors
  bool get hasError => errorMessage != null;

  /// Clear error message
  MeshState clearError() => copyWith(errorMessage: null);

  @override
  List<Object?> get props => [
    status,
    discoveredPeers,
    connectedPeers,
    receivedMessages,
    connectionState,
    localPeerId,
    isDiscovering,
    isConnecting,
    errorMessage,
  ];

  @override
  String toString() {
    return 'MeshState('
        'status: $status, '
        'discoveredPeers: ${discoveredPeers.length}, '
        'connectedPeers: ${connectedPeers.length}, '
        'messages: ${receivedMessages.length}, '
        'connectionState: $connectionState, '
        'localPeerId: $localPeerId, '
        'isDiscovering: $isDiscovering, '
        'isConnecting: $isConnecting, '
        'error: $errorMessage'
        ')';
  }
}
