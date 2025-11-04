import 'dart:async';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mesh_transport.dart';
import 'method_channel_mesh_transport.dart';

abstract class MeshTransportPlatform extends PlatformInterface {
  MeshTransportPlatform() : super(token: _token);

  static final Object _token = Object();
  static MeshTransportPlatform _instance = MethodChannelMeshTransport();
  static MeshTransportPlatform get instance => _instance;
  static set instance(MeshTransportPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  Stream<MeshPeer> get peers;
  Stream<Map<String, dynamic>> get messages;

  Future<void> discover();
  Future<void> stopDiscover();
  Future<void> advertise(String name);
  Future<void> stopAdvertise();
  Future<bool> connect(String peerId);
  Future<bool> send(String peerId, List<int> data);
}

