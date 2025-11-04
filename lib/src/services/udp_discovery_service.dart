import 'dart:async';
import 'dart:convert';
import 'dart:io';

class UdpDiscoveryService {
  static final UdpDiscoveryService _instance = UdpDiscoveryService._internal();
  factory UdpDiscoveryService() => _instance;
  static UdpDiscoveryService get instance => _instance;
  UdpDiscoveryService._internal();

  final _onPeer = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onPeer => _onPeer.stream;

  RawDatagramSocket? _socket;
  final InternetAddress _mcast = InternetAddress('239.255.255.250');
  final int _port = 43210;
  Timer? _beacon;
  String? _myId;

  Future<void> start({required String myId}) async {
    _myId = myId;
    if (_socket != null) return;
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port, reusePort: true);
    _socket!.joinMulticast(_mcast);
    _socket!.listen(_handlePacket);
    _beacon = Timer.periodic(const Duration(seconds: 3), (_) => _sendBeacon());
  }

  void _handlePacket(RawSocketEvent e) {
    if (e != RawSocketEvent.read) return;
    final dg = _socket!.receive();
    if (dg == null) return;
    try {
      final text = utf8.decode(dg.data);
      final map = jsonDecode(text) as Map<String, dynamic>;
      if (map['type'] == 'mesh_beacon' && map['id'] != _myId) {
        _onPeer.add(map);
      }
    } catch (_) {}
  }

  void _sendBeacon() {
    if (_socket == null || _myId == null) return;
    final payload = jsonEncode({
      'type': 'mesh_beacon',
      'id': _myId,
      'ts': DateTime.now().toIso8601String(),
    });
    _socket!.send(utf8.encode(payload), _mcast, _port);
  }

  Future<void> stop() async {
    _beacon?.cancel();
    _beacon = null;
    _socket?.close();
    _socket = null;
  }
}


