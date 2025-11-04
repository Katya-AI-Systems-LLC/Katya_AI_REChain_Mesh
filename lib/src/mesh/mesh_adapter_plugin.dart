import 'dart:async';
import 'package:mesh_transport/mesh_transport.dart' as plugin;
import '../services/mesh_service_ble.dart';
import 'mesh_adapter.dart';

class PluginMeshAdapter implements MeshAdapter {
  final _peers = StreamController<MeshPeer>.broadcast();
  final Map<String, MeshPeer> _seen = {};

  @override
  Future<void> startScan() async {
    plugin.MeshTransport.peers.listen((p) {
      final peer = MeshPeer(
        id: p.id,
        name: p.name,
        address: 'PLUGIN',
        rssi: p.rssi,
        lastSeen: DateTime.now(),
      );
      _seen[peer.id] = peer;
      _peers.add(peer);
    });
    await plugin.MeshTransport.discover();
  }

  @override
  Future<void> stopScan() async {
    await plugin.MeshTransport.stopDiscover();
  }

  @override
  Future<void> startAdvertise(String name) async {
    await plugin.MeshTransport.advertise(name);
  }

  @override
  Future<void> stopAdvertise() async {
    await plugin.MeshTransport.stopAdvertise();
  }

  @override
  Stream<MeshPeer> get peers => _peers.stream;

  @override
  Future<void> send(MeshMessage message) async {
    await plugin.MeshTransport.send(message.toId, message.message.codeUnits);
  }
}


