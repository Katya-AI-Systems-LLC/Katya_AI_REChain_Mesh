import '../services/mesh_service_ble.dart';

abstract class MeshAdapter {
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> startAdvertise(String name);
  Future<void> stopAdvertise();
  Stream<MeshPeer> get peers;
  Future<void> send(MeshMessage message);
}
