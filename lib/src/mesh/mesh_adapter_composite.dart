import 'dart:async';
import '../services/mesh_service_ble.dart';
import 'mesh_adapter.dart';

class CompositeMeshAdapter implements MeshAdapter {
  final List<MeshAdapter> _adapters;
  final _peers = StreamController<MeshPeer>.broadcast();
  final List<StreamSubscription> _subs = [];

  CompositeMeshAdapter(this._adapters);

  @override
  Future<void> startScan() async {
    for (final a in _adapters) {
      _subs.add(a.peers.listen(_peers.add));
      await a.startScan();
    }
  }

  @override
  Future<void> stopScan() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    for (final a in _adapters) {
      await a.stopScan();
    }
  }

  @override
  Future<void> startAdvertise(String name) async {
    for (final a in _adapters) {
      await a.startAdvertise(name);
    }
  }

  @override
  Future<void> stopAdvertise() async {
    for (final a in _adapters) {
      await a.stopAdvertise();
    }
  }

  @override
  Stream<MeshPeer> get peers => _peers.stream;

  @override
  Future<void> send(MeshMessage message) async {
    // Try all adapters; in future pick by route
    for (final a in _adapters) {
      await a.send(message);
    }
  }
}


