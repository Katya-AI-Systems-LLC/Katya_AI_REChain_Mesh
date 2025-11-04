import 'dart:async';

import '../../domain/peer.dart';
import '../../domain/repositories/peer_repository.dart';
import 'base_service.dart';

/// Service for managing peer discovery and communication
class PeerService implements LifecycleService, ErrorHandlingService {
  final PeerRepository _peerRepository;
  final StreamController<Peer> _peerUpdatesController = StreamController<Peer>.broadcast();
  final StreamController<ServiceError> _errorController = StreamController<ServiceError>.broadcast();
  
  bool _isInitialized = false;
  bool _isRunning = false;
  Timer? _discoveryTimer;
  
  /// Creates a new PeerService
  PeerService(this._peerRepository);
  
  @override
  String get serviceName => 'PeerService';
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get isRunning => _isRunning;
  
  @override
  Stream<ServiceError> get errors => _errorController.stream;
  
  /// Stream of peer updates (new peers, status changes, etc.)
  Stream<Peer> get peerUpdates => _peerUpdatesController.stream;
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _peerRepository.initialize();
      _isInitialized = true;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to initialize PeerService',
        e,
        stackTrace,
        ErrorSeverity.critical,
      );
      rethrow;
    }
  }
  
  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('PeerService must be initialized before starting');
    }
    
    if (_isRunning) return;
    
    try {
      // Start periodic peer discovery
      _startDiscoveryTimer();
      _isRunning = true;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to start PeerService',
        e,
        stackTrace,
        ErrorSeverity.critical,
      );
      rethrow;
    }
  }
  
  @override
  Future<void> stop() async {
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    _isRunning = false;
  }
  
  @override
  Future<void> dispose() async {
    await stop();
    await _peerUpdatesController.close();
    await _errorController.close();
    await _peerRepository.dispose();
    _isInitialized = false;
  }
  
  /// Discovers nearby peers
  Future<List<Peer>> discoverPeers() async {
    try {
      // Implementation will vary based on the transport layer
      // This is a placeholder for the actual discovery logic
      final peers = await _peerRepository.findAll();
      
      // Notify about discovered peers
      for (final peer in peers) {
        _peerUpdatesController.add(peer);
      }
      
      return peers;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to discover peers',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  /// Gets a peer by ID
  Future<Peer?> getPeer(String peerId) async {
    try {
      return await _peerRepository.findById(peerId);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to get peer $peerId',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
      return null;
    }
  }
  
  /// Updates a peer's information
  Future<void> updatePeer(Peer peer) async {
    try {
      await _peerRepository.save(peer);
      _peerUpdatesController.add(peer);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to update peer ${peer.id}',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  /// Updates a peer's status (online/offline)
  Future<void> updatePeerStatus(String peerId, bool isOnline) async {
    try {
      await _peerRepository.updateStatus(peerId, isOnline);
      final peer = await _peerRepository.findById(peerId);
      if (peer != null) {
        _peerUpdatesController.add(peer);
      }
    } catch (e, stackTrace) {
      _handleError(
        'Failed to update status for peer $peerId',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
    }
  }
  
  /// Updates a peer's location
  Future<void> updatePeerLocation(String peerId, GeoLocation location) async {
    try {
      await _peerRepository.updateLocation(peerId, location);
      final peer = await _peerRepository.findById(peerId);
      if (peer != null) {
        _peerUpdatesController.add(peer);
      }
    } catch (e, stackTrace) {
      _handleError(
        'Failed to update location for peer $peerId',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
    }
  }
  
  /// Finds nearby peers within a certain radius
  Future<List<Peer>> findNearbyPeers(GeoLocation location, double radiusMeters) async {
    try {
      return await _peerRepository.findNearby(location, radiusMeters);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to find nearby peers',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
      return [];
    }
  }
  
  /// Handles an error
  @override
  void handleError(ServiceError error) {
    _errorController.add(error);
  }
  
  // Starts the periodic peer discovery
  void _startDiscoveryTimer() {
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => discoverPeers().catchError((e) {
        _handleError(
          'Periodic peer discovery failed',
          e,
          StackTrace.current,
          ErrorSeverity.warning,
        );
      }),
    );
  }
  
  // Handles an error
  void _handleError(
    String message,
    dynamic error,
    StackTrace stackTrace, 
    ErrorSeverity severity,
  ) {
    final serviceError = ServiceError(
      message: '$message: $error',
      stackTrace: stackTrace,
      severity: severity,
    );
    _errorController.add(serviceError);
    
    // Log critical errors
    if (severity == ErrorSeverity.critical) {
      print('CRITICAL ERROR: $serviceError');
      print(stackTrace);
    }
  }
}
