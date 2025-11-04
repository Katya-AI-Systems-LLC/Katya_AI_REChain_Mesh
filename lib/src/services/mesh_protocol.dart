import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'crypto_helper.dart';

/// Расширенный протокол mesh-сети с маршрутизацией и QoS
class MeshProtocol {
  static final MeshProtocol _instance = MeshProtocol._internal();
  factory MeshProtocol() => _instance;
  static MeshProtocol get instance => _instance;
  MeshProtocol._internal();

  final StreamController<MeshPacket> _onPacketReceived =
      StreamController.broadcast();
  final StreamController<MeshNode> _onNodeDiscovered =
      StreamController.broadcast();
  final StreamController<MeshRoute> _onRouteUpdated =
      StreamController.broadcast();

  // Таблицы маршрутизации
  final Map<String, MeshNode> _nodes = {};
  final Map<String, MeshRoute> _routes = {};
  final Map<String, List<MeshPacket>> _packetQueue = {};

  // Настройки протокола
  final int _maxHops = 7;
  final int _packetTTL = 30;
  final Duration _routeTimeout = const Duration(minutes: 5);
  final Duration _heartbeatInterval = const Duration(seconds: 30);

  Stream<MeshPacket> get onPacketReceived => _onPacketReceived.stream;
  Stream<MeshNode> get onNodeDiscovered => _onNodeDiscovered.stream;
  Stream<MeshRoute> get onRouteUpdated => _onRouteUpdated.stream;

  /// Инициализация протокола
  Future<void> initialize() async {
    print('Initializing Mesh Protocol...');

    // Запускаем heartbeat
    Timer.periodic(_heartbeatInterval, (_) => _sendHeartbeat());

    // Очищаем устаревшие маршруты
    Timer.periodic(const Duration(minutes: 1), (_) => _cleanupRoutes());

    print('Mesh Protocol initialized');
  }

  /// Отправка пакета через mesh-сеть
  Future<void> sendPacket({
    required String destination,
    required MeshPacketType type,
    required Map<String, dynamic> payload,
    int priority = 0,
    bool requireAck = true,
  }) async {
    final packet = MeshPacket(
      id: _generatePacketId(),
      source: await _getNodeId(),
      destination: destination,
      type: type,
      payload: payload,
      priority: priority,
      ttl: _packetTTL,
      timestamp: DateTime.now(),
      requireAck: requireAck,
    );

    // Шифруем пакет
    final encryptedPacket = await _encryptPacket(packet);

    // Добавляем в очередь
    _addToQueue(encryptedPacket);

    // Отправляем
    await _forwardPacket(encryptedPacket);
  }

  /// Обработка входящего пакета
  Future<void> handleIncomingPacket(Uint8List data) async {
    try {
      final packet = await _decryptPacket(data);

      // Проверяем TTL
      if (packet.ttl <= 0) {
        print('Packet TTL expired: ${packet.id}');
        return;
      }

      // Проверяем, для нас ли пакет
      if (packet.destination == await _getNodeId()) {
        await _handleLocalPacket(packet);
      } else {
        // Пересылаем пакет дальше
        await _forwardPacket(packet);
      }
    } catch (e) {
      print('Error handling incoming packet: $e');
    }
  }

  /// Обнаружение узлов сети
  Future<void> discoverNodes() async {
    final discoveryPacket = MeshPacket(
      id: _generatePacketId(),
      source: await _getNodeId(),
      destination: 'BROADCAST',
      type: MeshPacketType.discovery,
      payload: {
        'nodeId': await _getNodeId(),
        'capabilities': await _getNodeCapabilities(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      priority: 1,
      ttl: _maxHops,
      timestamp: DateTime.now(),
      requireAck: false,
    );

    await _broadcastPacket(discoveryPacket);
  }

  /// Получение маршрута к узлу
  Future<MeshRoute?> getRoute(String destination) async {
    return _routes[destination];
  }

  /// Получение списка всех узлов
  List<MeshNode> getNodes() {
    return _nodes.values.toList();
  }

  /// Получение статистики сети
  MeshNetworkStats getNetworkStats() {
    return MeshNetworkStats(
      totalNodes: _nodes.length,
      activeRoutes: _routes.length,
      totalPackets:
          _packetQueue.values.fold(0, (sum, queue) => sum + queue.length),
      averageLatency: _calculateAverageLatency(),
      networkHealth: _calculateNetworkHealth(),
    );
  }

  // Приватные методы

  Future<void> _sendHeartbeat() async {
    final heartbeatPacket = MeshPacket(
      id: _generatePacketId(),
      source: await _getNodeId(),
      destination: 'BROADCAST',
      type: MeshPacketType.heartbeat,
      payload: {
        'nodeId': await _getNodeId(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'load': _calculateNodeLoad(),
      },
      priority: 0,
      ttl: 1,
      timestamp: DateTime.now(),
      requireAck: false,
    );

    await _broadcastPacket(heartbeatPacket);
  }

  Future<void> _handleLocalPacket(MeshPacket packet) async {
    switch (packet.type) {
      case MeshPacketType.message:
        _onPacketReceived.add(packet);
        break;
      case MeshPacketType.discovery:
        await _handleDiscoveryPacket(packet);
        break;
      case MeshPacketType.heartbeat:
        await _handleHeartbeatPacket(packet);
        break;
      case MeshPacketType.routeUpdate:
        await _handleRouteUpdatePacket(packet);
        break;
      case MeshPacketType.ack:
        await _handleAckPacket(packet);
        break;
    }
  }

  Future<void> _handleDiscoveryPacket(MeshPacket packet) async {
    final nodeId = packet.payload['nodeId'] as String;
    final capabilities = packet.payload['capabilities'] as Map<String, dynamic>;

    final node = MeshNode(
      id: nodeId,
      lastSeen: DateTime.now(),
      capabilities: capabilities,
      load: 0,
      latency: 0,
    );

    _nodes[nodeId] = node;
    _onNodeDiscovered.add(node);

    // Отправляем ответ с информацией о себе
    final responsePacket = MeshPacket(
      id: _generatePacketId(),
      source: await _getNodeId(),
      destination: nodeId,
      type: MeshPacketType.discovery,
      payload: {
        'nodeId': await _getNodeId(),
        'capabilities': await _getNodeCapabilities(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      priority: 1,
      ttl: _maxHops,
      timestamp: DateTime.now(),
      requireAck: false,
    );

    await _sendPacketToNode(nodeId, responsePacket);
  }

  Future<void> _handleHeartbeatPacket(MeshPacket packet) async {
    final nodeId = packet.payload['nodeId'] as String;
    final load = packet.payload['load'] as int;

    if (_nodes.containsKey(nodeId)) {
      _nodes[nodeId] = _nodes[nodeId]!.copyWith(
        lastSeen: DateTime.now(),
        load: load,
      );
    }
  }

  Future<void> _handleRouteUpdatePacket(MeshPacket packet) async {
    final routeData = packet.payload['route'] as Map<String, dynamic>;
    final route = MeshRoute.fromJson(routeData);

    _routes[route.destination] = route;
    _onRouteUpdated.add(route);
  }

  Future<void> _handleAckPacket(MeshPacket packet) async {
    // Обработка подтверждений
    print('Received ACK for packet: ${packet.payload['originalPacketId']}');
  }

  Future<void> _forwardPacket(MeshPacket packet) async {
    // Уменьшаем TTL
    final forwardedPacket = packet.copyWith(ttl: packet.ttl - 1);

    if (forwardedPacket.ttl <= 0) {
      print('Packet TTL expired during forwarding: ${packet.id}');
      return;
    }

    // Находим маршрут
    final route = _routes[packet.destination];
    if (route != null) {
      await _sendPacketToNode(route.nextHop, forwardedPacket);
    } else {
      // Flooding для неизвестных маршрутов
      await _broadcastPacket(forwardedPacket);
    }
  }

  Future<void> _broadcastPacket(MeshPacket packet) async {
    // Отправляем пакет всем соседним узлам
    for (final node in _nodes.values) {
      if (node.id != packet.source) {
        await _sendPacketToNode(node.id, packet);
      }
    }
  }

  Future<void> _sendPacketToNode(String nodeId, MeshPacket packet) async {
    // Здесь должна быть реальная отправка через Bluetooth
    // Пока что эмулируем
    print('Sending packet ${packet.id} to node $nodeId');
  }

  void _addToQueue(MeshPacket packet) {
    final queue = _packetQueue[packet.destination] ?? [];
    queue.add(packet);
    _packetQueue[packet.destination] = queue;
  }

  Future<MeshPacket> _encryptPacket(MeshPacket packet) async {
    final jsonData = jsonEncode(packet.toJson());
    final key = await _getSessionKey(packet.destination);
    final encrypted = await CryptoHelper.encrypt(jsonData, key);

    return packet.copyWith(
      payload: {
        'encrypted': encrypted['ciphertext'],
        'nonce': encrypted['nonce'],
        'mac': encrypted['mac'],
      },
    );
  }

  Future<MeshPacket> _decryptPacket(Uint8List data) async {
    final jsonString = utf8.decode(data);
    final jsonData = jsonDecode(jsonString);
    final packet = MeshPacket.fromJson(jsonData);

    if (packet.payload.containsKey('encrypted')) {
      final key = await _getSessionKey(packet.source);
      final decrypted = await CryptoHelper.decrypt({
        'ciphertext': packet.payload['encrypted'],
        'nonce': packet.payload['nonce'],
        'mac': packet.payload['mac'],
      }, key);

      final decryptedPayload = jsonDecode(decrypted);
      return packet.copyWith(payload: decryptedPayload);
    }

    return packet;
  }

  Future<String> _getNodeId() async {
    // Возвращаем уникальный ID узла
    return 'node_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<Map<String, dynamic>> _getNodeCapabilities() async {
    return {
      'maxHops': _maxHops,
      'supportedTypes': MeshPacketType.values.map((e) => e.toString()).toList(),
      'encryption': true,
      'compression': false,
      'version': '1.0.0',
    };
  }

  int _calculateNodeLoad() {
    return _packetQueue.values.fold(0, (sum, queue) => sum + queue.length);
  }

  double _calculateAverageLatency() {
    if (_nodes.isEmpty) return 0.0;

    final totalLatency =
        _nodes.values.fold(0.0, (sum, node) => sum + node.latency);
    return totalLatency / _nodes.length;
  }

  double _calculateNetworkHealth() {
    if (_nodes.isEmpty) return 0.0;

    final now = DateTime.now();
    final activeNodes = _nodes.values
        .where((node) => now.difference(node.lastSeen).inMinutes < 2)
        .length;

    return activeNodes / _nodes.length;
  }

  void _cleanupRoutes() {
    final now = DateTime.now();
    _routes.removeWhere(
        (key, route) => now.difference(route.lastUpdated).inMinutes > 5);
  }

  String _generatePacketId() {
    return 'pkt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  Future<List<int>> _getSessionKey(String nodeId) async {
    // Возвращаем сессионный ключ для узла
    return List.generate(32, (index) => Random().nextInt(256));
  }

  void dispose() {
    _onPacketReceived.close();
    _onNodeDiscovered.close();
    _onRouteUpdated.close();
  }
}

/// Типы пакетов mesh-сети
enum MeshPacketType {
  message,
  discovery,
  heartbeat,
  routeUpdate,
  ack,
  file,
  voice,
  video,
}

/// Пакет mesh-сети
class MeshPacket {
  final String id;
  final String source;
  final String destination;
  final MeshPacketType type;
  final Map<String, dynamic> payload;
  final int priority;
  final int ttl;
  final DateTime timestamp;
  final bool requireAck;

  const MeshPacket({
    required this.id,
    required this.source,
    required this.destination,
    required this.type,
    required this.payload,
    required this.priority,
    required this.ttl,
    required this.timestamp,
    required this.requireAck,
  });

  MeshPacket copyWith({
    String? id,
    String? source,
    String? destination,
    MeshPacketType? type,
    Map<String, dynamic>? payload,
    int? priority,
    int? ttl,
    DateTime? timestamp,
    bool? requireAck,
  }) {
    return MeshPacket(
      id: id ?? this.id,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      ttl: ttl ?? this.ttl,
      timestamp: timestamp ?? this.timestamp,
      requireAck: requireAck ?? this.requireAck,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'destination': destination,
      'type': type.toString(),
      'payload': payload,
      'priority': priority,
      'ttl': ttl,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'requireAck': requireAck,
    };
  }

  factory MeshPacket.fromJson(Map<String, dynamic> json) {
    return MeshPacket(
      id: json['id'],
      source: json['source'],
      destination: json['destination'],
      type: MeshPacketType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      payload: json['payload'],
      priority: json['priority'],
      ttl: json['ttl'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      requireAck: json['requireAck'],
    );
  }
}

/// Узел mesh-сети
class MeshNode {
  final String id;
  final DateTime lastSeen;
  final Map<String, dynamic> capabilities;
  final int load;
  final double latency;

  const MeshNode({
    required this.id,
    required this.lastSeen,
    required this.capabilities,
    required this.load,
    required this.latency,
  });

  MeshNode copyWith({
    String? id,
    DateTime? lastSeen,
    Map<String, dynamic>? capabilities,
    int? load,
    double? latency,
  }) {
    return MeshNode(
      id: id ?? this.id,
      lastSeen: lastSeen ?? this.lastSeen,
      capabilities: capabilities ?? this.capabilities,
      load: load ?? this.load,
      latency: latency ?? this.latency,
    );
  }
}

/// Маршрут в mesh-сети
class MeshRoute {
  final String destination;
  final String nextHop;
  final int hops;
  final double cost;
  final DateTime lastUpdated;

  const MeshRoute({
    required this.destination,
    required this.nextHop,
    required this.hops,
    required this.cost,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'nextHop': nextHop,
      'hops': hops,
      'cost': cost,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory MeshRoute.fromJson(Map<String, dynamic> json) {
    return MeshRoute(
      destination: json['destination'],
      nextHop: json['nextHop'],
      hops: json['hops'],
      cost: json['cost'].toDouble(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
    );
  }
}

/// Статистика сети
class MeshNetworkStats {
  final int totalNodes;
  final int activeRoutes;
  final int totalPackets;
  final double averageLatency;
  final double networkHealth;

  const MeshNetworkStats({
    required this.totalNodes,
    required this.activeRoutes,
    required this.totalPackets,
    required this.averageLatency,
    required this.networkHealth,
  });
}
