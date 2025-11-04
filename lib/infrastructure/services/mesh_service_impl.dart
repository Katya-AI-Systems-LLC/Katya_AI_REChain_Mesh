import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:katya_ai_rechain_mesh/core/domain/entities/peer.dart';
import 'package:katya_ai_rechain_mesh/core/domain/entities/message.dart';
import 'package:katya_ai_rechain_mesh/core/services/mesh_service.dart';

/// Implementation of MeshService using Bluetooth Low Energy (BLE)
class MeshServiceImpl implements MeshService {
  static const String _serviceUuid = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String _rxCharacteristicUuid = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String _txCharacteristicUuid = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final String _localPeerName;
  final String _deviceType;

  final StreamController<Message> _messageController = StreamController.broadcast();
  final StreamController<MeshConnectionState> _connectionStateController = StreamController.broadcast();

  final Map<String, BluetoothDevice> _connectedDevices = {};
  final Map<String, Peer> _discoveredPeers = {};
  final String _localPeerId;

  bool _isAdvertising = false;
  bool _isDiscovering = false;

  /// Create a new MeshService instance
  MeshServiceImpl({
    required String localPeerName,
    String? localPeerId,
    String deviceType = 'mobile',
  })  : _localPeerName = localPeerName,
        _deviceType = deviceType,
        _localPeerId = localPeerId ?? const Uuid().v4();

  @override
  Future<void> initialize() async {
    // Request Bluetooth permissions
    await _requestPermissions();

    // Listen for state changes
    _flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        _connectionStateController.add(MeshConnectionState.connected);
      } else {
        _connectionStateController.add(MeshConnectionState.disconnected);
      }
    });

    // Listen for scan results
    _flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        _handleDiscoveredDevice(result.device, result.rssi);
      }
    });

    // Listen for connection state changes
    _flutterBlue.connectedDevices.asStream().listen((devices) {
      for (var device in devices) {
        if (!_connectedDevices.containsKey(device.id.id)) {
          _connectedDevices[device.id.id] = device;
          _setupDeviceListeners(device);
        }
      }
    });
  }

  @override
  Future<void> startAdvertising() async {
    if (_isAdvertising) return;

    try {
      await _flutterBlue.stopAdvertising();

      // Advertise quantum service
      await _flutterBlue.startAdvertising(
        AdvData(
          serviceUuids: [_serviceUuid],
          localName: 'QuantumNode-${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      _connectionStateController.add(MeshConnectionState.advertising);
      _isAdvertising = true;
    } catch (e) {
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      await _flutterBlue.stopAdvertising();
      _isAdvertising = false;
      _connectionStateController.add(MeshConnectionState.connected);
    } catch (e) {
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Stream<List<Peer>> discoverPeers({
    Duration timeout = const Duration(seconds: 10),
    bool includeSignalStrength = true,
  }) async* {
    if (_isDiscovering) return;

    _isDiscovering = true;
    _connectionStateController.add(MeshConnectionState.discovering);

    try {
      await _flutterBlue.startScan(
        timeout: timeout,
        withServices: [_serviceUuid],
      );

      // Yield current discovered peers
      yield _discoveredPeers.values.toList();

      // Continue yielding updates until timeout
      final timer = Timer(timeout, () {
        _isDiscovering = false;
        _connectionStateController.add(MeshConnectionState.connected);
      });

      await for (final _ in Stream.periodic(const Duration(milliseconds: 500))) {
        if (!_isDiscovering) break;
        yield _discoveredPeers.values.toList();
      }

      timer.cancel();
    } catch (e) {
      _isDiscovering = false;
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    try {
      await _flutterBlue.stopScan();
      _isDiscovering = false;
      _connectionStateController.add(MeshConnectionState.connected);
    } catch (e) {
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> connect(String peerId) async {
    final device = _connectedDevices[peerId];
    if (device == null) {
      throw Exception('Device not found: $peerId');
    }

    try {
      await device.connect();
      _setupDeviceListeners(device);
    } catch (e) {
      _connectionStateController.add(MeshConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<void> disconnect(String peerId) async {
    final device = _connectedDevices[peerId];
    if (device != null) {
      await device.disconnect();
      _connectedDevices.remove(peerId);
    }
  }

  @override
  Future<void> sendMessage({
    required Message message,
    bool useQuantumChannel = false,
    int maxHops = 5,
  }) async {
    final messageJson = jsonEncode(message.toJson());
    final data = Uint8List.fromList(utf8.encode(messageJson));

    if (message.recipientIds.isEmpty) {
      // Broadcast to all connected devices
      for (final device in _connectedDevices.values) {
        await _sendDataToDevice(device, data);
      }
    } else {
      // Send to specific recipients
      for (final recipientId in message.recipientIds) {
        final device = _connectedDevices[recipientId];
        if (device != null) {
          await _sendDataToDevice(device, data);
        }
      }
    }
  }

  @override
  Future<void> broadcastMessage(Message message) async {
    final broadcastMessage = message.copyWith(recipientIds: []);
    await sendMessage(message: broadcastMessage);
  }

  @override
  Stream<Message> get messageStream => _messageController.stream;

  @override
  Stream<MeshConnectionState> get connectionStateStream => _connectionStateController.stream;

  @override
  List<Peer> get connectedPeers => _connectedDevices.keys
      .map((id) => _discoveredPeers[id])
      .where((peer) => peer != null)
      .cast<Peer>()
      .toList();

  @override
  String get localPeerId => _localPeerId;

  @override
  Future<void> dispose() async {
    await _flutterBlue.stopScan();
    await _flutterBlue.stopAdvertising();

    for (final device in _connectedDevices.values) {
      await device.disconnect();
    }

    _connectedDevices.clear();
    _discoveredPeers.clear();

    await _messageController.close();
    await _connectionStateController.close();
  }

  Future<void> _requestPermissions() async {
    // Request Bluetooth permissions
    // Implementation depends on the platform
    try {
      await _flutterBlue.turnOn();
    } catch (e) {
      // Handle error or request permissions
      rethrow;
    }
  }

  void _handleDiscoveredDevice(BluetoothDevice device, int rssi) {
    final peerId = device.id.id;

    // Skip our own device
    if (peerId == _localPeerId) return;

    // Update or add the peer
    _discoveredPeers[peerId] = Peer(
      id: peerId,
      name: device.name.isNotEmpty ? device.name : 'Unknown Device',
      deviceType: _deviceType,
      signalStrength: _convertRssiToPercentage(rssi),
      supportedProtocols: ['ble', 'mesh'],
    );
  }

  void _setupDeviceListeners(BluetoothDevice device) {
    device.state.listen((state) async {
      if (state == BluetoothDeviceState.disconnected) {
        _connectedDevices.remove(device.id.id);
        _connectionStateController.add(MeshConnectionState.disconnected);
      }
    });
  }

  Future<void> _sendDataToDevice(BluetoothDevice device, Uint8List data) async {
    try {
      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid.toString() == _serviceUuid,
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == _rxCharacteristicUuid,
      );

      await characteristic.write(data);
    } catch (e) {
      // Handle send error
      print('Error sending data to device ${device.id}: $e');
    }
  }

  int _convertRssiToPercentage(int rssi) {
    // Convert RSSI to a percentage (0-100)
    const minRssi = -100; // Minimum expected RSSI
    const maxRssi = -30;  // Maximum expected RSSI

    if (rssi >= maxRssi) return 100;
    if (rssi <= minRssi) return 0;

    return ((rssi - minRssi) * 100 / (maxRssi - minRssi)).round();
  }
}
