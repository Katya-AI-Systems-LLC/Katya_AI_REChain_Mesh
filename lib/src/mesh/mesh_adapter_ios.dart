// iOS adapter (stub) – to be wired to CoreBluetooth via MethodChannels
import 'mesh_adapter.dart';
import '../services/mesh_service_ble.dart';

class IOSMeshAdapter implements MeshAdapter {
  @override
  Future<void> startScan() async {}

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> startAdvertise(String name) async {}

  @override
  Future<void> stopAdvertise() async {}

  @override
  Stream<MeshPeer> get peers => const Stream.empty();

  @override
  Future<void> send(MeshMessage message) async {}
}
