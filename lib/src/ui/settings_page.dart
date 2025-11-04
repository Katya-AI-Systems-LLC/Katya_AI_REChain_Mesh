import 'package:flutter/material.dart';
import '../config/app_config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _provider = AppConfig.aiProvider;
  String _adapter = AppConfig.meshAdapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('AI провайдер'),
          DropdownButton<String>(
            value: _provider,
            items: const [
              DropdownMenuItem(value: 'local', child: Text('LocalAI')),
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _provider = v);
              // Note: dynamic switch would require re-init; for now, hint restart
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Перезапустите приложение для применения изменений')));
            },
          ),
          const SizedBox(height: 16),
          const Text('Mesh адаптер'),
          DropdownButton<String>(
            value: _adapter,
            items: const [
              DropdownMenuItem(value: 'emulated', child: Text('Emulated BLE')),
              DropdownMenuItem(value: 'android_ble', child: Text('Android BLE (native)')),
              DropdownMenuItem(value: 'ios_ble', child: Text('iOS BLE (native)')),
              DropdownMenuItem(value: 'nearby', child: Text('Nearby/Multipeer (plugin)')),
              DropdownMenuItem(value: 'composite', child: Text('Composite (BLE+Plugin)')),
              DropdownMenuItem(value: 'wifi_emulated', child: Text('Wi‑Fi Direct (emulated)')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _adapter = v);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Перезапустите приложение для применения изменений')));
            },
          ),
        ],
      ),
    );
  }
}
