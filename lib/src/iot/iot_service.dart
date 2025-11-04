import 'dart:async';
import 'dart:math';

/// Сервис интеграции с IoT устройствами
class IoTService {
  static final IoTService _instance = IoTService._internal();
  factory IoTService() => _instance;
  static IoTService get instance => _instance;
  IoTService._internal();

  final StreamController<IoTDevice> _onDeviceConnected =
      StreamController.broadcast();
  final StreamController<IoTDevice> _onDeviceDisconnected =
      StreamController.broadcast();
  final StreamController<SensorData> _onSensorDataReceived =
      StreamController.broadcast();

  // Данные
  final Map<String, IoTDevice> _devices = {};
  final Map<String, List<SensorData>> _sensorHistory = {};
  final Map<String, DeviceRule> _deviceRules = {};
  bool _isScanning = false;

  Stream<IoTDevice> get onDeviceConnected => _onDeviceConnected.stream;
  Stream<IoTDevice> get onDeviceDisconnected => _onDeviceDisconnected.stream;
  Stream<SensorData> get onSensorDataReceived => _onSensorDataReceived.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing IoT Service...');
    await _loadSampleDevices();
    await _loadDeviceRules();
    print('IoT Service initialized');
  }

  /// Начать сканирование IoT устройств
  Future<void> startScanning() async {
    if (_isScanning) return;

    _isScanning = true;
    print('Started scanning for IoT devices...');

    // Симулируем обнаружение устройств
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }

      _simulateDeviceDiscovery();
    });
  }

  /// Остановить сканирование
  void stopScanning() {
    _isScanning = false;
    print('Stopped scanning for IoT devices');
  }

  /// Подключение к устройству
  Future<bool> connectToDevice(String deviceId) async {
    final device = _devices[deviceId];
    if (device == null) {
      return false;
    }

    // Симулируем подключение
    await Future.delayed(const Duration(milliseconds: 500));

    final connectedDevice = device.copyWith(
      isConnected: true,
      lastSeen: DateTime.now(),
    );

    _devices[deviceId] = connectedDevice;
    _onDeviceConnected.add(connectedDevice);

    // Начинаем получение данных с датчиков
    _startSensorDataCollection(deviceId);

    return true;
  }

  /// Отключение от устройства
  Future<void> disconnectFromDevice(String deviceId) async {
    final device = _devices[deviceId];
    if (device == null || !device.isConnected) {
      return;
    }

    final disconnectedDevice = device.copyWith(
      isConnected: false,
      lastSeen: DateTime.now(),
    );

    _devices[deviceId] = disconnectedDevice;
    _onDeviceDisconnected.add(disconnectedDevice);
  }

  /// Получение списка устройств
  List<IoTDevice> getDevices({IoTDeviceType? type, bool? connectedOnly}) {
    var devices = _devices.values.toList();

    if (type != null) {
      devices = devices.where((d) => d.type == type).toList();
    }

    if (connectedOnly == true) {
      devices = devices.where((d) => d.isConnected).toList();
    }

    return devices;
  }

  /// Отправка команды устройству
  Future<bool> sendCommand({
    required String deviceId,
    required String command,
    Map<String, dynamic>? parameters,
  }) async {
    final device = _devices[deviceId];
    if (device == null || !device.isConnected) {
      return false;
    }

    // Симулируем отправку команды
    await Future.delayed(const Duration(milliseconds: 200));

    print('Command sent to ${device.name}: $command with params: $parameters');
    return true;
  }

  /// Получение истории данных датчиков
  List<SensorData> getSensorHistory({
    required String deviceId,
    String? sensorType,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final history = _sensorHistory[deviceId] ?? [];

    return history.where((data) {
      if (sensorType != null && data.type != sensorType) return false;
      if (startTime != null && data.timestamp.isBefore(startTime)) return false;
      if (endTime != null && data.timestamp.isAfter(endTime)) return false;
      return true;
    }).toList();
  }

  /// Создание правила автоматизации
  Future<DeviceRule> createRule({
    required String name,
    required String description,
    required String deviceId,
    required String sensorType,
    required String condition,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    final ruleId = _generateId();

    final rule = DeviceRule(
      id: ruleId,
      name: name,
      description: description,
      deviceId: deviceId,
      sensorType: sensorType,
      condition: condition,
      action: action,
      parameters: parameters ?? {},
      isActive: true,
      createdAt: DateTime.now(),
    );

    _deviceRules[ruleId] = rule;
    return rule;
  }

  /// Получение правил устройства
  List<DeviceRule> getDeviceRules(String deviceId) {
    return _deviceRules.values
        .where((rule) => rule.deviceId == deviceId)
        .toList();
  }

  /// Получение статистики
  Map<String, dynamic> getStatistics() {
    final totalDevices = _devices.length;
    final connectedDevices = _devices.values.where((d) => d.isConnected).length;
    final totalRules = _deviceRules.length;
    final activeRules = _deviceRules.values.where((r) => r.isActive).length;

    return {
      'total_devices': totalDevices,
      'connected_devices': connectedDevices,
      'total_rules': totalRules,
      'active_rules': activeRules,
      'is_scanning': _isScanning,
    };
  }

  // Приватные методы

  Future<void> _loadSampleDevices() async {
    final devices = [
      IoTDevice(
        id: 'sensor_001',
        name: 'Датчик температуры',
        type: IoTDeviceType.sensor,
        manufacturer: 'SmartHome Inc.',
        model: 'TempSensor Pro',
        macAddress: 'AA:BB:CC:DD:EE:01',
        isConnected: false,
        batteryLevel: 85,
        signalStrength: -45,
        lastSeen: DateTime.now(),
        capabilities: ['temperature', 'humidity'],
      ),
      IoTDevice(
        id: 'light_001',
        name: 'Умная лампа',
        type: IoTDeviceType.actuator,
        manufacturer: 'LightTech',
        model: 'SmartBulb RGB',
        macAddress: 'AA:BB:CC:DD:EE:02',
        isConnected: false,
        batteryLevel: 100,
        signalStrength: -30,
        lastSeen: DateTime.now(),
        capabilities: ['light_control', 'color_change', 'brightness'],
      ),
      IoTDevice(
        id: 'camera_001',
        name: 'IP камера',
        type: IoTDeviceType.camera,
        manufacturer: 'SecureCam',
        model: 'CamPro 4K',
        macAddress: 'AA:BB:CC:DD:EE:03',
        isConnected: false,
        batteryLevel: 0,
        signalStrength: -20,
        lastSeen: DateTime.now(),
        capabilities: ['video_stream', 'motion_detection', 'night_vision'],
      ),
      IoTDevice(
        id: 'lock_001',
        name: 'Умный замок',
        type: IoTDeviceType.security,
        manufacturer: 'SecureLock',
        model: 'SmartLock Pro',
        macAddress: 'AA:BB:CC:DD:EE:04',
        isConnected: false,
        batteryLevel: 60,
        signalStrength: -35,
        lastSeen: DateTime.now(),
        capabilities: ['lock_control', 'access_log', 'fingerprint'],
      ),
    ];

    for (final device in devices) {
      _devices[device.id] = device;
    }
  }

  Future<void> _loadDeviceRules() async {
    final rules = [
      DeviceRule(
        id: 'rule_001',
        name: 'Автоматическое освещение',
        description: 'Включать свет при движении',
        deviceId: 'light_001',
        sensorType: 'motion',
        condition: 'motion_detected == true',
        action: 'turn_on_light',
        parameters: {'brightness': 80},
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DeviceRule(
        id: 'rule_002',
        name: 'Контроль температуры',
        description: 'Уведомление о высокой температуре',
        deviceId: 'sensor_001',
        sensorType: 'temperature',
        condition: 'temperature > 30',
        action: 'send_notification',
        parameters: {'message': 'Высокая температура!'},
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    for (final rule in rules) {
      _deviceRules[rule.id] = rule;
    }
  }

  void _simulateDeviceDiscovery() {
    // Симулируем обнаружение нового устройства
    if (Random().nextDouble() < 0.3) {
      final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      final device = IoTDevice(
        id: deviceId,
        name: 'Новое устройство',
        type: IoTDeviceType.sensor,
        manufacturer: 'Unknown',
        model: 'Generic',
        macAddress:
            'AA:BB:CC:DD:EE:${Random().nextInt(100).toString().padLeft(2, '0')}',
        isConnected: false,
        batteryLevel: Random().nextInt(100),
        signalStrength: -Random().nextInt(50) - 20,
        lastSeen: DateTime.now(),
        capabilities: ['basic_sensor'],
      );

      _devices[deviceId] = device;
      _onDeviceConnected.add(device);
    }
  }

  void _startSensorDataCollection(String deviceId) {
    // Симулируем получение данных с датчиков
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final device = _devices[deviceId];
      if (device == null || !device.isConnected) {
        timer.cancel();
        return;
      }

      _generateSensorData(deviceId);
    });
  }

  void _generateSensorData(String deviceId) {
    final device = _devices[deviceId];
    if (device == null) return;

    final random = Random();
    final timestamp = DateTime.now();

    // Генерируем данные в зависимости от типа устройства
    switch (device.type) {
      case IoTDeviceType.sensor:
        final temperature = 20 + random.nextDouble() * 15;
        final humidity = 40 + random.nextDouble() * 40;

        _addSensorData(
            deviceId,
            SensorData(
              id: _generateId(),
              deviceId: deviceId,
              type: 'temperature',
              value: temperature,
              unit: '°C',
              timestamp: timestamp,
            ));

        _addSensorData(
            deviceId,
            SensorData(
              id: _generateId(),
              deviceId: deviceId,
              type: 'humidity',
              value: humidity,
              unit: '%',
              timestamp: timestamp,
            ));
        break;

      case IoTDeviceType.actuator:
        final powerConsumption = 5 + random.nextDouble() * 10;

        _addSensorData(
            deviceId,
            SensorData(
              id: _generateId(),
              deviceId: deviceId,
              type: 'power',
              value: powerConsumption,
              unit: 'W',
              timestamp: timestamp,
            ));
        break;

      case IoTDeviceType.camera:
        final motionDetected = random.nextDouble() < 0.1;

        if (motionDetected) {
          _addSensorData(
              deviceId,
              SensorData(
                id: _generateId(),
                deviceId: deviceId,
                type: 'motion',
                value: 1,
                unit: 'detected',
                timestamp: timestamp,
              ));
        }
        break;

      case IoTDeviceType.security:
        final doorOpen = random.nextDouble() < 0.05;

        if (doorOpen) {
          _addSensorData(
              deviceId,
              SensorData(
                id: _generateId(),
                deviceId: deviceId,
                type: 'door_status',
                value: 1,
                unit: 'open',
                timestamp: timestamp,
              ));
        }
        break;
    }
  }

  void _addSensorData(String deviceId, SensorData data) {
    final history = _sensorHistory[deviceId] ?? [];
    history.add(data);

    // Ограничиваем историю последними 100 записями
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }

    _sensorHistory[deviceId] = history;
    _onSensorDataReceived.add(data);

    // Проверяем правила автоматизации
    _checkDeviceRules(deviceId, data);
  }

  void _checkDeviceRules(String deviceId, SensorData data) {
    final rules = _deviceRules.values
        .where((rule) =>
            rule.deviceId == deviceId &&
            rule.sensorType == data.type &&
            rule.isActive)
        .toList();

    for (final rule in rules) {
      bool conditionMet = false;

      switch (rule.condition) {
        case 'temperature > 30':
          conditionMet = data.type == 'temperature' && data.value > 30;
          break;
        case 'motion_detected == true':
          conditionMet = data.type == 'motion' && data.value == 1;
          break;
        case 'humidity < 20':
          conditionMet = data.type == 'humidity' && data.value < 20;
          break;
      }

      if (conditionMet) {
        _executeRuleAction(rule);
      }
    }
  }

  void _executeRuleAction(DeviceRule rule) {
    print('Executing rule: ${rule.name} - Action: ${rule.action}');

    switch (rule.action) {
      case 'turn_on_light':
        sendCommand(
          deviceId: rule.deviceId,
          command: 'turn_on',
          parameters: rule.parameters,
        );
        break;
      case 'send_notification':
        print('Notification: ${rule.parameters['message']}');
        break;
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void dispose() {
    stopScanning();
    _onDeviceConnected.close();
    _onDeviceDisconnected.close();
    _onSensorDataReceived.close();
  }
}

// Модели данных

class IoTDevice {
  final String id;
  final String name;
  final IoTDeviceType type;
  final String manufacturer;
  final String model;
  final String macAddress;
  final bool isConnected;
  final int batteryLevel;
  final int signalStrength;
  final DateTime lastSeen;
  final List<String> capabilities;

  const IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.macAddress,
    required this.isConnected,
    required this.batteryLevel,
    required this.signalStrength,
    required this.lastSeen,
    required this.capabilities,
  });

  IoTDevice copyWith({
    String? id,
    String? name,
    IoTDeviceType? type,
    String? manufacturer,
    String? model,
    String? macAddress,
    bool? isConnected,
    int? batteryLevel,
    int? signalStrength,
    DateTime? lastSeen,
    List<String>? capabilities,
  }) {
    return IoTDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      macAddress: macAddress ?? this.macAddress,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalStrength: signalStrength ?? this.signalStrength,
      lastSeen: lastSeen ?? this.lastSeen,
      capabilities: capabilities ?? this.capabilities,
    );
  }
}

enum IoTDeviceType {
  sensor,
  actuator,
  camera,
  security,
  appliance,
  wearable,
}

class SensorData {
  final String id;
  final String deviceId;
  final String type;
  final double value;
  final String unit;
  final DateTime timestamp;

  const SensorData({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
}

class DeviceRule {
  final String id;
  final String name;
  final String description;
  final String deviceId;
  final String sensorType;
  final String condition;
  final String action;
  final Map<String, dynamic> parameters;
  final bool isActive;
  final DateTime createdAt;

  const DeviceRule({
    required this.id,
    required this.name,
    required this.description,
    required this.deviceId,
    required this.sensorType,
    required this.condition,
    required this.action,
    required this.parameters,
    required this.isActive,
    required this.createdAt,
  });
}
