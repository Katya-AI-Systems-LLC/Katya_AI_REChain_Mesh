part of 'mesh_bloc.dart';

/// Base class for mesh-related events
abstract class MeshEvent extends Equatable {
  const MeshEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the mesh network
class InitializeMesh extends MeshEvent {
  const InitializeMesh();
}

/// Event to start discovering nearby peers
class StartPeerDiscovery extends MeshEvent {
  final Duration timeout;
  final bool includeSignalStrength;

  const StartPeerDiscovery({
    this.timeout = const Duration(seconds: 10),
    this.includeSignalStrength = true,
  });

  @override
  List<Object?> get props => [timeout, includeSignalStrength];
}

/// Event to stop peer discovery
class StopPeerDiscovery extends MeshEvent {
  const StopPeerDiscovery();
}

/// Event to connect to a specific peer
class ConnectToPeer extends MeshEvent {
  final String peerId;

  const ConnectToPeer(this.peerId);

  @override
  List<Object?> get props => [peerId];
}

/// Event to disconnect from a specific peer
class DisconnectFromPeer extends MeshEvent {
  final String peerId;

  const DisconnectFromPeer(this.peerId);

  @override
  List<Object?> get props => [peerId];
}

/// Event to send a message to specific recipients
class SendMessageEvent extends MeshEvent {
  final Message message;
  final bool useQuantumChannel;
  final int maxHops;

  const SendMessageEvent({
    required this.message,
    this.useQuantumChannel = false,
    this.maxHops = 5,
  });

  @override
  List<Object?> get props => [message, useQuantumChannel, maxHops];
}

/// Event to broadcast a message to all connected peers
class BroadcastMessageEvent extends MeshEvent {
  final Message message;

  const BroadcastMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Internal event for peer updates
class _PeersUpdated extends MeshEvent {
  final List<Peer> peers;

  const _PeersUpdated(this.peers);

  @override
  List<Object?> get props => [peers];
}

/// Internal event for received messages
class _MessageReceived extends MeshEvent {
  final Message message;

  const _MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

/// Internal event for connection state changes
class _ConnectionStateChanged extends MeshEvent {
  final MeshConnectionState connectionState;

  const _ConnectionStateChanged(this.connectionState);

  @override
  List<Object?> get props => [connectionState];
}
