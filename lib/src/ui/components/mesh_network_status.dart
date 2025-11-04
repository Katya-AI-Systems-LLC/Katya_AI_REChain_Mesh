import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/mesh_service_ble.dart';

/// Виджет для отображения статуса mesh-сети
class MeshNetworkStatus extends StatelessWidget {
  const MeshNetworkStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final meshService = MeshServiceBLE.instance;
    final stats = meshService.getMeshStatistics();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KatyaTheme.primary.withOpacity(0.1),
            KatyaTheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KatyaTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.network_check,
                color: KatyaTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Mesh Network Status',
                style: KatyaTheme.heading3.copyWith(
                  color: KatyaTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Статус сети
          _buildStatusRow(
            'Network',
            stats['is_scanning'] == true ? 'Active' : 'Inactive',
            stats['is_scanning'] == true ? Colors.green : Colors.grey,
          ),

          const SizedBox(height: 8),

          // Пиры
          _buildStatusRow(
            'Connected Peers',
            '${stats['connected_peers']}/${stats['total_peers']}',
            stats['connected_peers'] as int > 0 ? Colors.green : Colors.grey,
          ),

          const SizedBox(height: 8),

          // Очередь сообщений
          _buildStatusRow(
            'Message Queue',
            '${stats['messages_in_queue']}',
            (stats['messages_in_queue'] as int) > 0
                ? Colors.orange
                : Colors.green,
          ),

          const SizedBox(height: 8),

          // Success rate
          _buildStatusRow(
            'Success Rate',
            '${stats['success_rate']}%',
            double.parse(stats['success_rate'] as String) > 80
                ? Colors.green
                : Colors.red,
          ),

          const SizedBox(height: 8),

          // Статистика
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip('Sent', '${stats['total_sent']}', Colors.blue),
              _buildStatChip(
                  'Delivered', '${stats['total_delivered']}', Colors.green),
              _buildStatChip(
                  'Retries', '${stats['total_retries']}', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: KatyaTheme.body.copyWith(
            color: KatyaTheme.textSecondary,
          ),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: KatyaTheme.body.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: KatyaTheme.heading3.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: KatyaTheme.caption.copyWith(
            color: KatyaTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
