import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_transport/mesh_transport.dart';

void main() {
  const channel = MethodChannel('katya.mesh/transport');
  const events = EventChannel('katya.mesh/transport/events');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ServicesBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'discover':
        case 'stopDiscover':
        case 'advertise':
        case 'stopAdvertise':
          return true;
        case 'connect':
        case 'send':
          return true;
      }
      return null;
    });

    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      events.name,
      (ByteData? message) async {
        // Simulate one peerFound event
        // EventChannel uses a method codec; easiest is to do nothing here.
        return null;
      },
    );
  });

  tearDown(() {
    ServicesBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(events.name, null);
  });

  test('discover/advertise/connect/send do not throw', () async {
    await MeshTransport.discover();
    await MeshTransport.advertise('Test');
    final ok1 = await MeshTransport.connect('peer-1');
    final ok2 = await MeshTransport.send('peer-1', [1, 2, 3]);
    await MeshTransport.stopDiscover();
    await MeshTransport.stopAdvertise();
    expect(ok1, isTrue);
    expect(ok2, isTrue);
  });
}

