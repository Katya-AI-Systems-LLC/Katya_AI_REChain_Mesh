// Android adapter using platform channels
import 'dart:async';
import 'mesh_adapter.dart';
import '../services/mesh_service_ble.dart';
import '../platform/ble_channel.dart';

class AndroidMeshAdapter implements MeshAdapter {
  final _peers = StreamController<MeshPeer>.broadcast();

  @override
  Future<void> startScan() async {
    // Listen to native events for peers
    BleChannel.events.listen((event) {
      if (event is Map) {
        final type = event['type'];
        if (type == 'peerFound') {
          final peer = MeshPeer(
            id: (event['id'] ?? '') as String,
            name: (event['name'] ?? 'Unknown') as String,
            address: (event['address'] ?? '') as String,
            rssi: (event['rssi'] ?? -60) as int,
            lastSeen: DateTime.now(),
          );
          _peers.add(peer);
        }
      }
    });
    await BleChannel.startScan();
  }

  @override
  Future<void> stopScan() async {
    await BleChannel.stopScan();
  }

  @override
  Future<void> startAdvertise(String name) async {
    await BleChannel.advertise(name);
  }

  @override
  Future<void> stopAdvertise() async {
    await BleChannel.stopAdvertise();
  }

  @override
  Stream<MeshPeer> get peers => _peers.stream;

  @override
  Future<void> send(MeshMessage message) async {
    await BleChannel.send({
      'id': message.id,
      'fromId': message.fromId,
      'toId': message.toId,
      'payload': message.message,
      'priority': message.priority.index,
      'ttl': message.ttl,
    });
  }
}
