import 'dart:async';

class MeshService {
  MeshService._();
  static final MeshService instance = MeshService._();

  final StreamController<Map<String, dynamic>> _onPeerFound = StreamController.broadcast();
  Stream<Map<String, dynamic>> get onPeerFound => _onPeerFound.stream;

  Future<void> start() async {
    // start BLE scan or Nearby discovery
  }

  Future<void> stop() async {
    // stop
  }

  Future<void> connect(String peerId) async {
    // connect/handshake
  }

  Future<void> sendMessage(String peerId, String payload) async {
    // encrypt & send
  }
}
