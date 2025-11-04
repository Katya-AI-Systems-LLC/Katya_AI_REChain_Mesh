import 'dart:async';
import '../services/mesh_service_ble.dart';
import 'mesh_adapter.dart';

class EmulatedMeshAdapter implements MeshAdapter {
  final _peers = StreamController<MeshPeer>.broadcast();

  @override
  Future<void> startScan() async {
    // Forward from MeshServiceBLE for now
    MeshServiceBLE.instance.onPeerFound.listen(_peers.add);
    await MeshServiceBLE.instance.startMeshNetwork();
  }

  @override
  Future<void> stopScan() async {
    await MeshServiceBLE.instance.stopMeshNetwork();
  }

  @override
  Future<void> startAdvertise(String name) async {
    // No-op in emulation; MeshServiceBLE already emulates advertising logs
  }

  @override
  Future<void> stopAdvertise() async {
    // No-op in emulation
  }

  @override
  Stream<MeshPeer> get peers => _peers.stream;

  @override
  Future<void> send(MeshMessage message) async {
    await MeshServiceBLE.instance.sendMeshMessage(message.toId, message.message,
        priority: message.priority);
  }
}
