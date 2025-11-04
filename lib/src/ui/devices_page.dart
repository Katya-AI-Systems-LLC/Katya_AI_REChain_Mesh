import 'package:flutter/material.dart';
import '../services/mesh_service_ble.dart';
import '../theme.dart';
import 'components/mesh_network_status.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final MeshServiceBLE _mesh = MeshServiceBLE.instance;
  List<MeshPeer> peers = [];
  bool isScanning = false;
  String? connectedDeviceId;

  @override
  void initState() {
    super.initState();
    _mesh.onPeerFound.listen((peer) {
      setState(() {
        // avoid duplicates by id
        if (!peers.any((e) => e.id == peer.id)) {
          peers.add(peer);
        }
      });
    });
    _startScanning();
  }

  @override
  void dispose() {
    _mesh.stopScan();
    super.dispose();
  }

  void _startScanning() async {
    setState(() {
      isScanning = true;
      peers.clear();
    });
    await _mesh.startScan();
  }

  void _stopScanning() async {
    setState(() {
      isScanning = false;
    });
    await _mesh.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Заголовок и кнопки управления
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ближайшие устройства',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: KatyaTheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                onPressed: isScanning ? _stopScanning : _startScanning,
                icon: Icon(
                  isScanning ? Icons.stop : Icons.refresh,
                  color: KatyaTheme.accent,
                ),
                tooltip: isScanning ? 'Остановить поиск' : 'Начать поиск',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mesh Network Status
          const MeshNetworkStatus(),
          const SizedBox(height: 16),

          // Статус сканирования
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KatyaTheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isScanning ? KatyaTheme.success : KatyaTheme.warning,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isScanning ? KatyaTheme.success : KatyaTheme.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isScanning ? 'Поиск устройств...' : 'Поиск остановлен',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: KatyaTheme.onSurface),
                ),
                if (isScanning) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        KatyaTheme.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Список устройств
          Expanded(
            child: peers.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    itemCount: peers.length,
                    itemBuilder: (context, index) {
                      final peer = peers[index];
                      final isConnected = connectedDeviceId == peer.id;

                      return _buildDeviceCard(context, peer, isConnected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: KatyaTheme.accentGradient,
              boxShadow: KatyaTheme.spaceShadow,
            ),
            child: const Icon(
              Icons.bluetooth_searching,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Устройства не найдены',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: KatyaTheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Убедитесь, что Bluetooth включен\nи другие устройства находятся рядом',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: KatyaTheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startScanning,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить поиск'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    MeshPeer peer,
    bool isConnected,
  ) {
    final deviceName = peer.name;
    final rssi = peer.rssi;
    final signalStrength = _getSignalStrength(rssi);
    final signalColor = signalStrength['color'] as Color;
    final signalLabel = signalStrength['label'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка устройства
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isConnected
                      ? KatyaTheme.accentGradient
                      : LinearGradient(
                          colors: [
                            KatyaTheme.surface,
                            KatyaTheme.surface.withOpacity(0.7),
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isConnected ? KatyaTheme.accent : KatyaTheme.surface)
                              .withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.device_hub,
                  color: isConnected ? Colors.white : KatyaTheme.onSurface,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Информация об устройстве
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: KatyaTheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 16,
                          color: signalColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rssi dBm',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: KatyaTheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(width: 16),
                        if (isConnected) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KatyaTheme.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: KatyaTheme.success),
                            ),
                            child: Text(
                              'Подключено',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: KatyaTheme.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Кнопка подключения
              ElevatedButton(
                onPressed: isConnected ? _disconnect : () => _connect(peer),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isConnected ? KatyaTheme.error : KatyaTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isConnected ? 'Отключить' : 'Подключить',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _connect(MeshPeer peer) async {
    try {
      await _mesh.connectTo(peer.id);
      setState(() {
        connectedDeviceId = peer.id;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Подключено к ${peer.name}'),
            backgroundColor: KatyaTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка подключения: $e'),
            backgroundColor: KatyaTheme.error,
          ),
        );
      }
    }
  }

  void _disconnect() async {
    try {
      await _mesh.disconnect();
      setState(() {
        connectedDeviceId = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Отключено'),
            backgroundColor: KatyaTheme.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка отключения: $e'),
            backgroundColor: KatyaTheme.error,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _getSignalStrength(int rssi) {
    if (rssi >= -50) {
      return {'color': KatyaTheme.success, 'label': 'Отличный'};
    } else if (rssi >= -70) {
      return {'color': KatyaTheme.warning, 'label': 'Хороший'};
    } else if (rssi >= -85) {
      return {'color': KatyaTheme.tertiary, 'label': 'Слабый'};
    } else {
      return {'color': KatyaTheme.error, 'label': 'Очень слабый'};
    }
  }
}
