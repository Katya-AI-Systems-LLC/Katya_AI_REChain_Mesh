import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'src/mesh_transport_platform_interface.dart';

class MeshPeer {
  final String id;
  final String name;
  final int rssi;
  const MeshPeer({required this.id, required this.name, required this.rssi});
}

class MeshTransport {
  static MeshTransportPlatform get _platform => MeshTransportPlatform.instance;

  static Future<void> discover() => _platform.discover();
  static Future<void> stopDiscover() => _platform.stopDiscover();
  static Future<void> advertise(String name) => _platform.advertise(name);
  static Future<void> stopAdvertise() => _platform.stopAdvertise();
  static Future<bool> connect(String peerId) => _platform.connect(peerId);
  static Future<bool> send(String peerId, List<int> data) => _platform.send(peerId, data);
  static Stream<Map<String, dynamic>> get messages => _platform.messages;
  static Stream<MeshPeer> get peers => _platform.peers;

  static Future<void> sendFile(String peerId, String path, {int chunkSize = 32 * 1024}) async {
    final f = File(path);
    final name = path.split(Platform.pathSeparator).last;
    final total = await f.length();
    await send(peerId, _frame({'type': 'file:start', 'name': name, 'size': total}));
    final raf = await f.open();
    try {
      int sent = 0;
      while (sent < total) {
        final toRead = (total - sent) < chunkSize ? (total - sent) : chunkSize;
        final bytes = await raf.read(toRead);
        await send(peerId, _frame({'type': 'file:chunk', 'offset': sent, 'data': bytes}));
        sent += bytes.length;
      }
    } finally {
      await raf.close();
    }
    await send(peerId, _frame({'type': 'file:end', 'name': name}));
  }
}

List<int> _frame(Map<String, dynamic> map) {
  final json = const JsonEncoder().convert(map);
  return json.codeUnits;
}

