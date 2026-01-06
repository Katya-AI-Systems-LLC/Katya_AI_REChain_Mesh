import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/src/enhanced_theme.dart';
import 'package:katya_ai_rechain_mesh/src/ui/components/enhanced_ui_components.dart';
import '../services/mesh_service_ble.dart';
import '../theme.dart';

/// Улучшенная страница устройств с лучшим UX
class EnhancedDevicesPage extends StatefulWidget {
  const EnhancedDevicesPage({super.key});

  @override
  State<EnhancedDevicesPage> createState() => _EnhancedDevicesPageState();
}

class _EnhancedDevicesPageState extends State<EnhancedDevicesPage> {
  final MeshServiceBLE _mesh = MeshServiceBLE.instance;
  bool isScanning = false;
  List<Map<String, dynamic>> nearbyDevices = [];
  List<Map<String, dynamic>> connectedDevices = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDevices();
  }

  Future<void> _initializeDevices() async {
    setState(() => _isInitialized = false);
    try {
      await _loadDevices();
      _mesh.deviceStream.listen((device) {
        _loadDevices();
      });
    } catch (e) {
      print('Error initializing devices: $e');
    }
    setState(() => _isInitialized = true);
  }

  Future<void> _loadDevices() async {
    try {
      final devices = _mesh.scanResults;
      final connected = _mesh.connectedPeers;

      setState(() {
        nearbyDevices = devices;
        connectedDevices = connected;
      });
    } catch (e) {
      print('Error loading devices: $e');
    }
  }

  void _startScanning() async {
    setState(() => isScanning = true);
    try {
      await _mesh.startScan();
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          _stopScanning();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning: $e')),
      );
      setState(() => isScanning = false);
    }
  }

  void _stopScanning() async {
    setState(() => isScanning = false);
    try {
      await _mesh.stopScan();
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EnhancedTheme.darkBg,
      child: RefreshIndicator(
        backgroundColor: EnhancedTheme.darkSurface,
        color: EnhancedTheme.accent,
        onRefresh: () async {
          await _loadDevices();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Заголовок с кнопками управления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ближайшие устройства',
                      style: EnhancedTheme.headingS,
                    ),
                    Text(
                      'Найдено: ${nearbyDevices.length}',
                      style: EnhancedTheme.bodyS,
                    ),
                  ],
                ),
                FloatingActionButton.extended(
                  onPressed: isScanning ? _stopScanning : _startScanning,
                  icon: Icon(isScanning ? Icons.stop_rounded : Icons.refresh_rounded),
                  label: Text(isScanning ? 'Стоп' : 'Сканировать'),
                  backgroundColor: isScanning ? EnhancedTheme.error : EnhancedTheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Статус подключения
            if (!_isInitialized)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (connectedDevices.isNotEmpty) ...[
              Text(
                'Подключенные устройства',
                style: EnhancedTheme.titleL,
              ),
              const SizedBox(height: 12),
              ...connectedDevices
                  .map((device) => _buildConnectedDeviceCard(device))
                  .toList(),
              const SizedBox(height: 24),
            ],

            // Список близких устройств
            if (nearbyDevices.isEmpty && !isScanning)
              EmptyState(
                icon: Icons.devices_outlined,
                title: 'Устройства не найдены',
                subtitle: 'Нажмите кнопку сканировать для поиска устройств',
                action: ElevatedButton.icon(
                  onPressed: _startScanning,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Начать сканирование'),
                ),
              )
            else if (nearbyDevices.isEmpty && isScanning)
              Column(
                children: [
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(EnhancedTheme.accent),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Поиск устройств...',
                    style: EnhancedTheme.bodyM,
                  ),
                  const SizedBox(height: 40),
                ],
              )
            else ...[
              Text(
                'Доступные устройства',
                style: EnhancedTheme.titleL,
              ),
              const SizedBox(height: 12),
              ...nearbyDevices
                  .map((device) => _buildDeviceCard(device))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceCard(Map<String, dynamic> device) {
    final signalStrength = device['signal_strength'] as int? ?? -80;
    final rssiPercentage = ((signalStrength + 100) * 2).clamp(0, 100);

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      backgroundColor: EnhancedTheme.darkSurface.withOpacity(0.8),
      onTap: () => _showDeviceDetails(device),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: EnhancedTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.devices_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device['name'] ?? 'Unknown Device',
                        style: EnhancedTheme.titleM,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusIndicator(
                      isActive: true,
                      activeColor: EnhancedTheme.success,
                      size: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_4_bar_rounded,
                      size: 16,
                      color: _getSignalColor(rssiPercentage),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rssiPercentage.toStringAsFixed(0)}% · ${device['distance'] ?? 'N/A'} m',
                      style: EnhancedTheme.bodyS,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showDeviceMenu(device),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final signalStrength = device['signal_strength'] as int? ?? -80;
    final rssiPercentage = ((signalStrength + 100) * 2).clamp(0, 100);

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      onTap: () => _connectToDevice(device),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EnhancedTheme.darkSurfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EnhancedTheme.border),
            ),
            child: const Center(
              child: Icon(
                Icons.devices_outlined,
                color: EnhancedTheme.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device['name'] ?? 'Unknown Device',
                  style: EnhancedTheme.titleM,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_4_bar_rounded,
                      size: 16,
                      color: _getSignalColor(rssiPercentage),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rssiPercentage.toStringAsFixed(0)}% · ${device['distance'] ?? 'N/A'} m',
                      style: EnhancedTheme.bodyS,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: EnhancedTheme.accent,
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(double percentage) {
    if (percentage >= 66) return EnhancedTheme.success;
    if (percentage >= 33) return EnhancedTheme.warning;
    return EnhancedTheme.error;
  }

  void _connectToDevice(Map<String, dynamic> device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Подключение к ${device['name']}...'),
        backgroundColor: EnhancedTheme.accent,
      ),
    );
  }

  void _showDeviceDetails(Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EnhancedTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: EnhancedTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(device['name'] ?? 'Device', style: EnhancedTheme.headingS),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.info_rounded),
            title: const Text('MAC Address'),
            subtitle: Text(device['address'] ?? 'N/A'),
          ),
          ListTile(
            leading: const Icon(Icons.signal_cellular_4_bar_rounded),
            title: const Text('Signal Strength'),
            subtitle: Text('${device['signal_strength']} dBm'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_rounded),
            title: const Text('Distance'),
            subtitle: Text('${device['distance'] ?? 'N/A'} m'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Закрыть'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDeviceMenu(Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EnhancedTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: EnhancedTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.info_rounded),
            title: const Text('Информация'),
            onTap: () {
              Navigator.pop(context);
              _showDeviceDetails(device);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close_rounded),
            title: const Text('Отключить'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Устройство отключено')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
