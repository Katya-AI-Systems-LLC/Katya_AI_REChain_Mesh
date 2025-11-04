import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
// This test simulates MeshServiceBLE behavior using a fake class.
// It doesn't use actual BLE hardware; it's a unit-level simulation.

class FakeMeshService {
  final List<Map<String, dynamic>> _found = [];
  final List<String> sent = [];
  Stream<Map<String, dynamic>> get onPeerFound async* {
    for (var p in _found) {
      yield p;
    }
  }

  void addPeer(Map<String, dynamic> p) => _found.add(p);
  Future<void> sendMessage(String message) async {
    // simulate send delay
    await Future.delayed(const Duration(milliseconds: 10));
    sent.add(message);
  }
}

void main() {
  test('FakeMeshService discovery and send', () async {
    final svc = FakeMeshService();
    final uuid = const Uuid().v4();
    svc.addPeer({'id': uuid, 'name': 'peer1', 'rssi': -60});
    final events = <Map<String, dynamic>>[];
    final sub = svc.onPeerFound.listen((e) => events.add(e));
    // allow stream to emit
    await Future.delayed(const Duration(milliseconds: 50));
    expect(events.length, greaterThanOrEqualTo(1));
    await svc.sendMessage('hello');
    expect(svc.sent, contains('hello'));
    await sub.cancel();
  });
}
