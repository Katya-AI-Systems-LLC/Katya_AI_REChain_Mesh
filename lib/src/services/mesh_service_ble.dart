import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'crypto_helper.dart';
import '../mesh/mesh_adapter.dart';
import '../mesh/mesh_adapter_emulated.dart';
import '../mesh/mesh_adapter_android.dart';
import '../mesh/mesh_adapter_ios.dart';
import '../mesh/mesh_adapter_wifi_emulated.dart';
import '../mesh/mesh_adapter_plugin.dart';
import '../mesh/mesh_adapter_composite.dart';
import '../config/app_config.dart';
import 'udp_discovery_service.dart';

/// Mesh устройство (пир)
class MeshPeer {
  final String id;
  final String name;
  final String address;
  final int rssi;
  final DateTime lastSeen;
  final Map<String, dynamic> capabilities;

  MeshPeer({
    required this.id,
    required this.name,
    required this.address,
    required this.rssi,
    required this.lastSeen,
    Map<String, dynamic>? capabilities,
  }) : capabilities = capabilities ?? {};

  bool get isConnected => DateTime.now().difference(lastSeen).inSeconds < 10;
  bool get isStrongSignal => rssi > -70;
}

/// Mesh сообщение с приоритетом
class MeshMessage {
  final String id;
  final String fromId;
  final String toId;
  final String message;
  final DateTime timestamp;
  int ttl; // Time to live
  final List<String> path; // Маршрут доставки
  final Map<String, dynamic> metadata;
  final MessagePriority priority;
  int _retryCount;
  DateTime _lastRetry;

  MeshMessage({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.message,
    required this.timestamp,
    this.ttl = 10,
    List<String>? path,
    Map<String, dynamic>? metadata,
    this.priority = MessagePriority.normal,
  })  : path = path ?? [],
        metadata = metadata ?? {},
        _retryCount = 0,
        _lastRetry = DateTime.now();

  bool get isExpired => ttl <= 0;
  int get hopCount => path.length;
  int get retryCount => _retryCount;

  void incrementRetry() {
    _retryCount++;
    _lastRetry = DateTime.now();
  }

  bool get canRetry => _retryCount < _getMaxRetries();

  int _getMaxRetries() {
    switch (priority) {
      case MessagePriority.high:
        return 5;
      case MessagePriority.normal:
        return 3;
      case MessagePriority.low:
        return 1;
    }
  }

  bool shouldRetry() {
    if (!canRetry) return false;
    final secondsSinceRetry = DateTime.now().difference(_lastRetry).inSeconds;
    return secondsSinceRetry >= 5; // Retry каждые 5 секунд
  }
}

enum MessagePriority {
  low,
  normal,
  high,
}

class MeshServiceBLE {
  static final MeshServiceBLE _instance = MeshServiceBLE._internal();
  factory MeshServiceBLE() => _instance;
  static MeshServiceBLE get instance => _instance;
  MeshServiceBLE._internal() {
    _adapterName = AppConfig.meshAdapter;
    _adapter = _createAdapter();
  }
  late MeshAdapter _adapter;
  late String _adapterName;

  final StreamController<MeshPeer> _onPeerFound = StreamController.broadcast();
  final StreamController<MeshMessage> _onMessageReceived =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _onConnectionStatusChanged =
      StreamController.broadcast();

  // Mesh-сеть
  final Map<String, MeshPeer> _peers = {}; // Все известные пиры
  final Map<String, List<String>> _routingTable = {}; // Таблица маршрутизации
  final List<MeshMessage> _messageQueue = []; // Очередь сообщений
  final Set<String> _deliveredMessageIds = {}; // Доставленные сообщения
  final Map<String, DateTime> _awaitingAck = {}; // messageId -> sent time

  // QoS throttling per priority
  DateTime _lastHighSent = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastNormalSent = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastLowSent = DateTime.fromMillisecondsSinceEpoch(0);

  // Статистика mesh-сети
  int _totalMessagesSent = 0;
  int _totalMessagesDelivered = 0;
  int _totalMessagesFailed = 0;
  int _totalRetriesCount = 0;
  int _networkRestartCount = 0;
  DateTime? _lastSuccessfulConnection;

  // Session key for AES-GCM (32 bytes)
  List<int>? _sessionKey;
  String? _myDeviceId;
  String? _connectedDeviceId;
  bool _isScanning = false;
  bool _isAdvertising = false;
  bool _autoReconnectEnabled = true;
  Timer? _scanTimer;
  Timer? _advertisingTimer;
  Timer? _routingTimer;
  Timer? _healthCheckTimer; // kept for future native integrations
  Timer? _persistTimer;
  String? _stateFilePath;

  Stream<MeshPeer> get onPeerFound => _onPeerFound.stream;
  Stream<MeshMessage> get onMessageReceived => _onMessageReceived.stream;
  Stream<Map<String, dynamic>> get onConnectionStatusChanged =>
      _onConnectionStatusChanged.stream;

  String get myDeviceId => _myDeviceId ??= _generateDeviceId();

  List<MeshPeer> get peers => _peers.values.toList();
  List<MeshPeer> get connectedPeers =>
      _peers.values.where((p) => p.isConnected).toList();

  /// Инициализация Bluetooth
  Future<void> initialize() async {
    try {
      print('Mesh service initialized: my device ID = $myDeviceId');

      // Load persisted state if available
      await _loadState();

      // Запуск периодической обработки маршрутизации
      _startRoutingProcess();

      // Запуск health check для мониторинга стабильности
      _startHealthCheck();

      // UDP multicast discovery (best-effort, local network visibility)
      try {
        await UdpDiscoveryService.instance.start(myId: myDeviceId);
        UdpDiscoveryService.instance.onPeer.listen((map) {
          final pid = map['id'] as String?;
          if (pid == null) return;
          final p = MeshPeer(
            id: pid,
            name: 'UDP Peer $pid',
            address: 'UDP_MCAST',
            rssi: -40,
            lastSeen: DateTime.now(),
          );
          _peers[p.id] = p;
          _onPeerFound.add(p);
        });
      } catch (e) {
        print('UDP discovery unavailable: $e');
      }

      print('Bluetooth initialized successfully (emulated)');
    } catch (e) {
      print('Failed to initialize Bluetooth: $e');
      rethrow;
    }
  }

  /// Мониторинг здоровья mesh-сети
  void _startHealthCheck() {
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkNetworkHealth();
    });
  }

  /// Проверка здоровья сети
  void _checkNetworkHealth() {
    final connectedCount = connectedPeers.length;
    final queueSize = _messageQueue.length;
    final hasRecentConnection = _lastSuccessfulConnection != null &&
        DateTime.now().difference(_lastSuccessfulConnection!).inSeconds < 30;

    // Если нет подключенных пиров и есть сообщения в очереди - пробуем перезапустить сеть
    if (connectedCount == 0 && queueSize > 0 && _autoReconnectEnabled) {
      print('Network health check: No connected peers, attempting restart...');
      _restartMeshNetwork();
    }

    // Если последнее успешное подключение было давно - пробуем реконнект
    if (!hasRecentConnection && connectedCount == 0 && _isScanning) {
      print(
          'Network health check: No recent connections, attempting reconnect...');
      _attemptReconnect();
    }
  }

  /// Перезапуск mesh-сети
  Future<void> _restartMeshNetwork() async {
    if (_networkRestartCount > 5) {
      print('Too many restart attempts, disabling auto-reconnect');
      _autoReconnectEnabled = false;
      return;
    }

    _networkRestartCount++;
    print('Restarting mesh network (attempt $_networkRestartCount)...');

    await stopMeshNetwork();
    await Future.delayed(const Duration(seconds: 2));
    await startMeshNetwork();
  }

  /// Попытка реконнекта
  Future<void> _attemptReconnect() async {
    await stopScan();
    await stopAdvertising();
    await Future.delayed(const Duration(seconds: 1));
    await startMeshNetwork();
  }

  /// Автоматическое обнаружение устройств и построение mesh-сети
  Future<void> startMeshNetwork() async {
    await startScan();
    await startAdvertising('KATYA_MESH_${myDeviceId.substring(0, 8)}');
  }

  /// Остановка mesh-сети
  Future<void> stopMeshNetwork() async {
    await stopScan();
    await stopAdvertising();
    _routingTimer?.cancel();
  }

  /// Запуск сканирования BLE устройств
  Future<void> startScan() async {
    try {
      await stopScan();
      _isScanning = true;
      print('Starting mesh scan via adapter: $_adapterName');
      _adapter.peers.listen((p) {
        _peers[p.id] = p;
        _updateRoutingTable(p.id);
        _onPeerFound.add(p);
        // Try flushing pending messages to this peer on (re)appearance
        _flushPendingFor(p.id);
      });
      await _adapter.startScan();
    } catch (e) {
      print('Failed to start BLE scan: $e');
      _isScanning = false;
      rethrow;
    }
  }

  /// Остановка сканирования BLE устройств
  Future<void> stopScan() async {
    try {
      _scanTimer?.cancel();
      _isScanning = false;
      await _adapter.stopScan();
      print('BLE scan stopped');
    } catch (e) {
      print('Failed to stop BLE scan: $e');
    }
  }

  /// Начало рекламы BLE
  Future<void> startAdvertising(String deviceName) async {
    try {
      await stopAdvertising();

      _isAdvertising = true;
      print('Starting advertising via adapter: $_adapterName');
      await _adapter.startAdvertise(deviceName);
      if (_adapterName == 'emulated' || _adapterName == 'wifi_emulated') {
        _advertisingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          print('Emulating advertising: $deviceName');
        });
      }
    } catch (e) {
      print('Failed to start BLE advertising: $e');
      _isAdvertising = false;
      rethrow;
    }
  }

  /// Остановка рекламы BLE
  Future<void> stopAdvertising() async {
    try {
      _advertisingTimer?.cancel();
      _isAdvertising = false;
      await _adapter.stopAdvertise();
      print('Advertising stopped');
    } catch (e) {
      print('Failed to stop BLE advertising: $e');
    }
  }

  /// Подключение к устройству
  Future<void> connectTo(String deviceId) async {
    try {
      if (_connectedDeviceId != null) {
        await disconnect();
      }

      print('Connecting to device: $deviceId (emulated)');

      // Эмулируем подключение
      await Future.delayed(const Duration(seconds: 2));

      _connectedDeviceId = deviceId;

      _onConnectionStatusChanged.add({
        'type': 'connected',
        'deviceId': deviceId,
        'deviceName': 'Emulated Device $deviceId',
      });

      print('Connected to device: $deviceId (emulated)');
    } catch (e) {
      print('Failed to connect to device: $e');
      _connectedDeviceId = null;
      rethrow;
    }
  }

  /// Отключение от устройства
  Future<void> disconnect() async {
    try {
      if (_connectedDeviceId != null) {
        _connectedDeviceId = null;
        _onConnectionStatusChanged.add({
          'type': 'disconnected',
        });
        print('Disconnected from device (emulated)');
      }
    } catch (e) {
      print('Failed to disconnect: $e');
    }
  }

  /// Отправка сообщения
  Future<void> sendMessage(String message) async {
    if (_connectedDeviceId == null) {
      throw Exception('No connection to device');
    }

    try {
      // Шифруем сообщение если есть сессионный ключ
      String messageToSend = message;
      if (_sessionKey != null) {
        final encrypted = await CryptoHelper.encrypt(message, _sessionKey!);
        messageToSend = jsonEncode({
          'type': 'encrypted',
          'ciphertext': encrypted['ciphertext'],
          'nonce': encrypted['nonce'],
          'mac': encrypted['mac'],
        });
      } else {
        messageToSend = jsonEncode({
          'type': 'plain',
          'message': message,
        });
      }

      print('Message sent successfully: $messageToSend (emulated)');

      // Эмулируем получение ответа
      Timer(const Duration(seconds: 1), () {
        final echoMessage = MeshMessage(
          id: _generateMessageId(),
          fromId: _connectedDeviceId!,
          toId: myDeviceId,
          message: 'Echo: $message',
          timestamp: DateTime.now(),
          ttl: 5,
        );
        _onMessageReceived.add(echoMessage);
      });
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  /// Установка сессионного ключа
  void setSessionKey(List<int> key) {
    _sessionKey = key;
    print('Session key set');
  }

  /// Получение сессионного ключа
  List<int>? get sessionKey => _sessionKey;

  /// Проверка подключения
  bool get isConnected => _connectedDeviceId != null;

  /// Получение ID подключенного устройства
  String? get connectedDeviceId => _connectedDeviceId;

  /// Проверка сканирования
  bool get isScanning => _isScanning;

  /// Проверка рекламы
  bool get isAdvertising => _isAdvertising;

  /// Отправка сообщения через mesh-сеть
  Future<void> sendMeshMessage(
    String toId,
    String message, {
    MessagePriority priority = MessagePriority.normal,
    String type = 'chat',
  }) async {
    final meshMessage = MeshMessage(
      id: _generateMessageId(),
      fromId: myDeviceId,
      toId: toId,
      message: message,
      timestamp: DateTime.now(),
      ttl: 10,
      path: [myDeviceId],
      priority: priority,
      metadata: {'type': type},
    );

    _messageQueue.add(meshMessage);
    _totalMessagesSent++;
    print(
        'Mesh message queued: ${meshMessage.id} -> $toId (priority: $priority)');
    _schedulePersist();

    // Попытка немедленной доставки
    await _tryDeliverMessage(meshMessage);
    // Also pass to adapter for platform transmission when direct
    if (toId != myDeviceId) {
      await _adapter.send(meshMessage);
    }
  }

  /// Попытка доставки сообщения
  Future<void> _tryDeliverMessage(MeshMessage message) async {
    if (message.toId == myDeviceId) {
      // Это сообщение для нас
      _onMessageReceived.add(message);
      _deliveredMessageIds.add(message.id);
      print('Message delivered: ${message.id}');
      _messageQueue.remove(message);
      return;
    }

    // Проверяем, можем ли мы доставить напрямую
    if (_peers.containsKey(message.toId) && _peers[message.toId]!.isConnected) {
      print('Direct delivery to: ${message.toId}');
      _deliveredMessageIds.add(message.id);
      _messageQueue.remove(message);
      return;
    }

    // Ищем маршрут через соседей
    final route = _findRoute(message.toId);
    if (route.isNotEmpty) {
      final nextHop = route[0];
      print('Forwarding message to next hop: $nextHop');

      // Симулируем пересылку
      Timer(const Duration(milliseconds: 500), () {
        _onMessageReceived.add(message);
        _deliveredMessageIds.add(message.id);
        _messageQueue.remove(message);
      });
    }
  }

  /// Поиск маршрута к получателю
  List<String> _findRoute(String toId) {
    if (_routingTable.containsKey(toId)) {
      return _routingTable[toId]!;
    }

    // Flood fill алгоритм
    final connected = connectedPeers.where((p) => p.isStrongSignal).toList();
    if (connected.isNotEmpty) {
      return [connected.first.id];
    }

    return [];
  }

  /// Обновление таблицы маршрутизации
  void _updateRoutingTable(String peerId) {
    if (!_routingTable.containsKey(peerId)) {
      _routingTable[peerId] = [peerId];
    }

    // Обновляем маршруты через этого пира
    for (final targetId in _peers.keys) {
      if (targetId != peerId && !_routingTable.containsKey(targetId)) {
        _routingTable[targetId] = [peerId, targetId];
      }
    }
  }

  /// Запуск процесса маршрутизации
  void _startRoutingProcess() {
    _routingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _processMessageQueue();
      _updatePeerStatus();
      _retryAwaitingAcks();
    });
  }

  /// Обработка очереди сообщений с retry механизмом
  void _processMessageQueue() {
    // final now = DateTime.now();

    // Сортируем по приоритету: высокий приоритет - первым
    final sortedMessages = _messageQueue.toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    for (final message in sortedMessages) {
      if (_isAck(message)) {
        // Ack messages bypass throttling, deliver immediately
        final delivered = _tryDeliverMessageSync(message);
        if (!delivered) {
          // keep TTL mechanics
          message.ttl = message.ttl - 1;
        }
        continue;
      }

      // rate limiting per priority (ms spacing)
      final now = DateTime.now();
      final spacing = _spacingFor(message.priority);
      final last = _lastFor(message.priority);
      if (now.difference(last) < spacing) {
        continue;
      }

      // decrement TTL per cycle
      message.ttl = message.ttl - 1;

      if (message.isExpired) {
        _messageQueue.remove(message);
        _totalMessagesFailed++;
        continue;
      }

      if (_deliveredMessageIds.contains(message.id)) {
        _messageQueue.remove(message);
        _totalMessagesDelivered++;
        continue;
      }

      // Пробуем доставить или ретраить
      final delivered = _tryDeliverMessageSync(message);
      if (!delivered) {
        if (message.shouldRetry()) {
          message.incrementRetry();
          _totalRetriesCount++;
          print(
              'Retrying message ${message.id} (attempt ${message.retryCount}/${message._getMaxRetries()})');
        }
      } else {
        _recordSent(message.priority);
      }
    }
    _schedulePersist();
  }

  /// Синхронная попытка доставки сообщения
  bool _tryDeliverMessageSync(MeshMessage message) {
    // Handle ACKs
    if (_isAck(message)) {
      final ackId = message.metadata['ackFor'] as String?;
      if (ackId != null) {
        _awaitingAck.remove(ackId);
      }
      _deliveredMessageIds.add(message.id);
      _messageQueue.remove(message);
      _totalMessagesDelivered++;
      _schedulePersist();
      return true;
    }

    // Broadcast handling (emulated): deliver locally and mark delivered
    if (message.toId == 'broadcast') {
      _onMessageReceived.add(message);
      _deliveredMessageIds.add(message.id);
      _messageQueue.remove(message);
      _totalMessagesDelivered++;
      _schedulePersist();
      return true;
    }

    if (message.toId == myDeviceId) {
      // Это сообщение для нас
      _onMessageReceived.add(message);
      // Send ACK back
      final ack = MeshMessage(
        id: _generateMessageId(),
        fromId: myDeviceId,
        toId: message.fromId,
        message: 'ack',
        timestamp: DateTime.now(),
        ttl: 5,
        path: [myDeviceId],
        priority: MessagePriority.high,
        metadata: {'type': 'ack', 'ackFor': message.id},
      );
      _messageQueue.add(ack);
      _deliveredMessageIds.add(message.id);
      _messageQueue.remove(message);
      print('Message delivered: ${message.id}');
      _totalMessagesDelivered++;
      _schedulePersist();
      return true;
    }

    // Проверяем, можем ли мы доставить напрямую
    if (_peers.containsKey(message.toId) && _peers[message.toId]!.isConnected) {
      print('Direct delivery to: ${message.toId}');
      _deliveredMessageIds.add(message.id);
      _messageQueue.remove(message);
      _totalMessagesDelivered++;
      _lastSuccessfulConnection = DateTime.now();
      _awaitingAck[message.id] = DateTime.now();
      _schedulePersist();
      return true;
    }

    // Ищем маршрут через соседей
    final route = _findRoute(message.toId);
    if (route.isNotEmpty) {
      final nextHop = route[0];
      print('Forwarding message to next hop: $nextHop');
      // Добавляем текущий узел в path и имитируем доставку в следующий хоп
      message.path.add(myDeviceId);
      _deliveredMessageIds.add(message.id);
      _messageQueue.remove(message);
      _totalMessagesDelivered++;
      _lastSuccessfulConnection = DateTime.now();
      _awaitingAck[message.id] = DateTime.now();
      _schedulePersist();
      return true;
    }

    // Ограниченный gossip: выбрать сильного соседа, не встречавшегося в path
    final candidates = connectedPeers
        .where((p) => p.isStrongSignal && !message.path.contains(p.id))
        .toList();
    if (candidates.isNotEmpty) {
      final nextHop = candidates.first.id;
      print('Gossip forwarding to: $nextHop');
      message.path.add(myDeviceId);
      _deliveredMessageIds.add(message.id);
      _messageQueue.remove(message);
      _totalMessagesDelivered++;
      _lastSuccessfulConnection = DateTime.now();
      _schedulePersist();
      return true;
    }

    return false;
  }

  bool _isAck(MeshMessage m) => (m.metadata['type'] as String?) == 'ack';

  Duration _spacingFor(MessagePriority p) {
    switch (p) {
      case MessagePriority.high:
        return const Duration(milliseconds: 50);
      case MessagePriority.normal:
        return const Duration(milliseconds: 150);
      case MessagePriority.low:
        return const Duration(milliseconds: 350);
    }
  }

  DateTime _lastFor(MessagePriority p) {
    switch (p) {
      case MessagePriority.high:
        return _lastHighSent;
      case MessagePriority.normal:
        return _lastNormalSent;
      case MessagePriority.low:
        return _lastLowSent;
    }
  }

  void _recordSent(MessagePriority p) {
    final now = DateTime.now();
    switch (p) {
      case MessagePriority.high:
        _lastHighSent = now;
        break;
      case MessagePriority.normal:
        _lastNormalSent = now;
        break;
      case MessagePriority.low:
        _lastLowSent = now;
        break;
    }
  }

  void _retryAwaitingAcks() {
    final now = DateTime.now();
    final stale = _awaitingAck.entries
        .where((e) => now.difference(e.value).inSeconds > 5)
        .map((e) => e.key)
        .toList();
    if (stale.isEmpty) return;
    for (final id in stale) {
      // If original message still present, bump retry; otherwise skip
      final index = _messageQueue.indexWhere((m) => m.id == id);
      if (index >= 0) {
        _messageQueue[index].incrementRetry();
      }
      _awaitingAck.remove(id);
    }
  }

  void _flushPendingFor(String peerId) {
    // Attempt immediate delivery of messages queued for this peer
    final pending = _messageQueue.where((m) => m.toId == peerId).toList();
    if (pending.isEmpty) return;
    for (final m in pending) {
      _tryDeliverMessageSync(m);
    }
  }

  /// Обновление статуса пиров
  void _updatePeerStatus() {
    // final now = DateTime.now();

    for (final peer in _peers.values.toList()) {
      if (!peer.isConnected) {
        _peers.remove(peer.id);
        print('Peer disconnected: ${peer.name}');
      }
    }
  }

  /// Получение статистики mesh-сети
  Map<String, dynamic> getMeshStatistics() {
    final successRate = _totalMessagesSent > 0
        ? (_totalMessagesDelivered / _totalMessagesSent * 100)
            .toStringAsFixed(1)
        : '0.0';

    return {
      'my_device_id': myDeviceId,
      'adapter': _adapterName,
      'total_peers': _peers.length,
      'connected_peers': connectedPeers.length,
      'messages_in_queue': _messageQueue.length,
      'delivered_messages': _deliveredMessageIds.length,
      'routing_table_size': _routingTable.length,
      'is_scanning': _isScanning,
      'is_advertising': _isAdvertising,
      'total_sent': _totalMessagesSent,
      'total_delivered': _totalMessagesDelivered,
      'total_failed': _totalMessagesFailed,
      'total_retries': _totalRetriesCount,
      'success_rate': '$successRate%',
      'network_restarts': _networkRestartCount,
      'auto_reconnect_enabled': _autoReconnectEnabled,
      'last_successful_connection':
          _lastSuccessfulConnection?.toIso8601String(),
    };
  }

  // Persistence helpers
  Future<void> _ensureStateFilePath() async {
    if (_stateFilePath != null) return;
    final dir = await getApplicationSupportDirectory();
    _stateFilePath = '${dir.path}${Platform.pathSeparator}mesh_state.json';
  }

  Future<void> _loadState() async {
    try {
      await _ensureStateFilePath();
      final f = File(_stateFilePath!);
      if (!await f.exists()) return;
      final text = await f.readAsString();
      final data = jsonDecode(text) as Map<String, dynamic>;
      final delivered = (data['delivered'] as List<dynamic>? ?? []).cast<String>();
      _deliveredMessageIds
        ..clear()
        ..addAll(delivered);
      final queue = (data['queue'] as List<dynamic>? ?? []);
      _messageQueue
        ..clear()
        ..addAll(queue.map((e) => _meshMessageFromMap((e as Map).cast<String, dynamic>())));
      print('Loaded mesh state: ${_messageQueue.length} queued, ${_deliveredMessageIds.length} delivered');
    } catch (e) {
      print('Failed to load mesh state: $e');
    }
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 400), _saveState);
  }

  Future<void> _saveState() async {
    try {
      await _ensureStateFilePath();
      final f = File(_stateFilePath!);
      final data = {
        'delivered': _deliveredMessageIds.toList(),
        'queue': _messageQueue.map(_meshMessageToMap).toList(),
      };
      await f.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Failed to save mesh state: $e');
    }
  }

  Map<String, dynamic> _meshMessageToMap(MeshMessage m) => {
        'id': m.id,
        'fromId': m.fromId,
        'toId': m.toId,
        'message': m.message,
        'timestamp': m.timestamp.toIso8601String(),
        'ttl': m.ttl,
        'path': m.path,
        'metadata': m.metadata,
        'priority': m.priority.index,
        'retryCount': m.retryCount,
      };

  MeshMessage _meshMessageFromMap(Map<String, dynamic> map) => MeshMessage(
        id: map['id'] as String,
        fromId: map['fromId'] as String,
        toId: map['toId'] as String,
        message: map['message'] as String,
        timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
        ttl: (map['ttl'] as int?) ?? 10,
        path: (map['path'] as List<dynamic>? ?? const []).cast<String>(),
        metadata: (map['metadata'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        priority: MessagePriority.values[(map['priority'] as int?)?.clamp(0, 2) ?? 1],
      );

  /// Очистка очередей/состояния (для демо)
  Future<void> clearState() async {
    _messageQueue.clear();
    _deliveredMessageIds.clear();
    _awaitingAck.clear();
    _schedulePersist();
  }

  /// Генерация уникального ID устройства
  String _generateDeviceId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(9999).toString().padLeft(4, '0');
    return 'mesh_${timestamp}_$randomPart';
  }

  /// Генерация уникального ID сообщения
  String _generateMessageId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(99999).toString().padLeft(5, '0');
    return 'msg_${timestamp}_$randomPart';
  }

  /// Очистка ресурсов
  void dispose() {
    _scanTimer?.cancel();
    _advertisingTimer?.cancel();
    _routingTimer?.cancel();
    _healthCheckTimer?.cancel();
    _persistTimer?.cancel();
    _onPeerFound.close();
    _onMessageReceived.close();
    _onConnectionStatusChanged.close();
  }

  MeshAdapter _createAdapter() {
    switch (_adapterName) {
      case 'wifi_emulated':
        return EmulatedWifiDirectAdapter();
      case 'android_ble':
        return AndroidMeshAdapter();
      case 'ios_ble':
        return IOSMeshAdapter();
      case 'plugin':
      case 'nearby':
      case 'multipeer':
        return PluginMeshAdapter();
      case 'composite':
        return CompositeMeshAdapter([
          EmulatedMeshAdapter(),
          PluginMeshAdapter(),
        ]);
      case 'emulated':
      default:
        return EmulatedMeshAdapter();
    }
  }

  /// Change adapter at runtime and restart mesh network
  Future<void> setAdapter(String name) async {
    if (name == _adapterName) return;
    try {
      await stopMeshNetwork();
      _adapterName = name;
      _adapter = _createAdapter();
      await startMeshNetwork();
      print('Adapter switched to: $_adapterName');
    } catch (e) {
      print('Failed to switch adapter: $e');
      rethrow;
    }
  }
}
