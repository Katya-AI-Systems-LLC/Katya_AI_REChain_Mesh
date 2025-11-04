import 'dart:async';
import 'package:flutter/services.dart';
import '../mesh_transport.dart';
import 'mesh_transport_platform_interface.dart';

class MethodChannelMeshTransport extends MeshTransportPlatform {
  static const MethodChannel _channel = MethodChannel('katya.mesh/transport');
  static const EventChannel _events = EventChannel('katya.mesh/transport/events');

  final StreamController<MeshPeer> _peersCtrl = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _messagesCtrl = StreamController.broadcast();
  bool _listening = false;

  MethodChannelMeshTransport() {
    _ensureListen();
  }

  void _ensureListen() {
    if (_listening) return;
    _listening = true;
    _events.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final type = event['type'];
        if (type == 'peerFound') {
          _peersCtrl.add(MeshPeer(
            id: (event['id'] ?? '') as String,
            name: (event['name'] ?? 'Unknown') as String,
            rssi: (event['rssi'] ?? -60) as int,
          ));
        } else if (type == 'message') {
          _messagesCtrl.add(event.cast<String, dynamic>());
        }
      }
    });
  }

  @override
  Stream<MeshPeer> get peers => _peersCtrl.stream;

  @override
  Stream<Map<String, dynamic>> get messages => _messagesCtrl.stream;

  @override
  Future<void> discover() => _channel.invokeMethod('discover');

  @override
  Future<void> stopDiscover() => _channel.invokeMethod('stopDiscover');

  @override
  Future<void> advertise(String name) => _channel.invokeMethod('advertise', {'name': name});

  @override
  Future<void> stopAdvertise() => _channel.invokeMethod('stopAdvertise');

  @override
  Future<bool> connect(String peerId) async {
    final ok = await _channel.invokeMethod('connect', {'peerId': peerId});
    return ok == true;
  }

  @override
  Future<bool> send(String peerId, List<int> data) async {
    final ok = await _channel.invokeMethod('send', {'peerId': peerId, 'data': data});
    return ok == true;
  }
}

