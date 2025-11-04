import 'dart:async';
import '../services/mesh_service_ble.dart';
import 'mesh_adapter.dart';

class EmulatedWifiDirectAdapter implements MeshAdapter {
  final _peers = StreamController<MeshPeer>.broadcast();

  @override
  Future<void> startScan() async {
    // Emulate Wi‑Fi Direct discovery similar to BLE emulation
    Timer.periodic(const Duration(seconds: 4), (t) {
      final id = 'wifi-${DateTime.now().millisecondsSinceEpoch % 1000}';
      final p = MeshPeer(
        id: id,
        name: 'Wi‑Fi Peer $id',
        address: 'WFD_ADDR_$id',
        rssi: -40,
        lastSeen: DateTime.now(),
      );
      _peers.add(p);
    });
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> startAdvertise(String name) async {}

  @override
  Future<void> stopAdvertise() async {}

  @override
  Stream<MeshPeer> get peers => _peers.stream;

  @override
  Future<void> send(MeshMessage message) async {}
}
