import '../../domain/peer.dart';
import 'base_repository.dart';

/// Repository for managing Peer entities
abstract class PeerRepository extends BaseRepository<Peer> {
  /// Finds a peer by its public key
  Future<Peer?> findByPublicKey(String publicKey);
  
  /// Finds peers by their role
  Future<List<Peer>> findByRole(PeerRole role);
  
  /// Finds nearby peers within a certain radius (in meters)
  Future<List<Peer>> findNearby(GeoLocation location, double radiusMeters);
  
  /// Finds peers that support a specific transport type
  Future<List<Peer>> findByTransport(TransportType transport);
  
  /// Updates the last known location of a peer
  Future<void> updateLocation(String peerId, GeoLocation location);
  
  /// Updates the status of a peer (online/offline)
  Future<void> updateStatus(String peerId, bool isOnline);
  
  /// Stream of online peers
  Stream<List<Peer>> watchOnlinePeers();
  
  /// Stream of nearby peers
  Stream<List<Peer>> watchNearbyPeers(GeoLocation location, double radiusMeters);
}
