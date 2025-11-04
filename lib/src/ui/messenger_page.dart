import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mesh_service_ble.dart';
import '../app_state.dart';
import '../models/message.dart' as model;
import '../services/ai/offline_ai_helper.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({super.key});

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  final MeshServiceBLE _mesh = MeshServiceBLE.instance;
  final OfflineAIHelper _ai = OfflineAIHelper.instance;
  final List<MeshMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  StreamSubscription<MeshMessage>? _sub;
  List<String> _aiSuggestions = [];
  bool _showSuggestions = false;
  

  @override
  void initState() {
    super.initState();
    // Load persisted messages (best-effort)
    final app = Provider.of<AppState>(context, listen: false);
    () async {
      await app.initialize();
      setState(() {});
    }();
    _sub = _mesh.onMessageReceived.listen((m) async {
      setState(() => _messages.insert(0, m));
      // persist
      final app = Provider.of<AppState>(context, listen: false);
      try {
        await app.addMessage(model.Message(
          id: m.id,
          fromId: m.fromId,
          toId: m.toId,
          body: m.message,
          ts: m.timestamp,
        ));
        // Generate AI suggestions based on recent messages
        final recent = _messages.take(3).map((e) => e.message).toList();
        final suggestions = await _ai.suggestReplies(recent);
        if (mounted) {
          setState(() {
            _aiSuggestions = suggestions;
            _showSuggestions = true;
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final peers = _mesh.connectedPeers;
    if (peers.isEmpty) {
      // Нет прямых пиров — отправляем broadcast, чтобы доставить по мере появления
      await _mesh.sendMeshMessage('broadcast', text, type: 'chat');
    } else {
      await _mesh.sendMeshMessage(peers.first.id, text, type: 'chat');
    }
    // persist our own message
    final app = Provider.of<AppState>(context, listen: false);
    await app.addMessage(model.Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromId: _mesh.myDeviceId,
      toId: peers.isEmpty ? 'broadcast' : peers.first.id,
      body: text,
      ts: DateTime.now(),
    ));
    _controller.clear();
  }

  Future<void> _attach() async {
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attach image (label only)'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'filename.jpg')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    final label = '📎 image: $name';
    final peers = _mesh.connectedPeers;
    await _mesh.sendMeshMessage(peers.isEmpty ? 'broadcast' : peers.first.id, label, type: 'attachment');
    final app = Provider.of<AppState>(context, listen: false);
    await app.addMessage(model.Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromId: _mesh.myDeviceId,
      toId: peers.isEmpty ? 'broadcast' : peers.first.id,
      body: label,
      ts: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final stats = _mesh.getMeshStatistics();
    final peersCount = stats['connected_peers'] as int? ?? 0;
    final app = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Mesh Messenger'),
          const SizedBox(width: 12),
          Hero(
            tag: 'mesh_peers_count',
            child: Chip(label: Text('peers: $peersCount')),
          ),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              reverse: true,
              children: [
                // AI suggestions banner
                if (_showSuggestions && _aiSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, size: 18, color: Colors.blue),
                            const SizedBox(width: 6),
                            const Text('Katya AI предлагает:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => _showSuggestions = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _aiSuggestions.map((s) => ActionChip(
                                label: Text(s),
                                onPressed: () {
                                  _controller.text = s;
                                  setState(() => _showSuggestions = false);
                                },
                              )).toList(),
                        ),
                      ],
                    ),
                  ),
                // in-memory session messages first
                ..._messages.map((m) => ListTile(
                      title: Text(m.message),
                      subtitle: Text('${m.fromId} → ${m.toId} • ${m.timestamp.toIso8601String()}'),
                    )),
                // persisted history (older)
                ...app.messages.map((mm) => ListTile(
                      title: Text(mm.body),
                      subtitle: Text('${mm.fromId} → ${mm.toId} • ${mm.ts.toIso8601String()}'),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(onPressed: _attach, icon: const Icon(Icons.attach_file)),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type message'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _send, child: const Text('Send')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
