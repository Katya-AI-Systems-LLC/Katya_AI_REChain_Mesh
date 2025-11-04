import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/mesh_service_ble.dart';
import '../../theme.dart';
import '../../services/voting_service.dart';

class MeshHud extends StatefulWidget {
  const MeshHud({super.key});

  @override
  State<MeshHud> createState() => _MeshHudState();
}

class _MeshHudState extends State<MeshHud> {
  final MeshServiceBLE _mesh = MeshServiceBLE.instance;
  Map<String, dynamic> _stats = const {};
  bool _expanded = false;
  Timer? _timer;
  Offset _offset = const Offset(16, 16);
  bool _screencast = false;
  final List<Timer> _demoTimers = [];
  String? _adapter;
  static const _adapters = <String>[
    'emulated',
    'wifi_emulated',
    'android_ble',
    'ios_ble',
    'plugin',
    'composite',
  ];

  @override
  void initState() {
    super.initState();
    _pull();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _pull());
  }

  void _pull() {
    setState(() {
      _stats = _mesh.getMeshStatistics();
      _adapter = (_stats['adapter'] as String?) ?? _adapter;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopScreencast();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peers = _stats['connected_peers'] ?? 0;
    final queue = _stats['messages_in_queue'] ?? 0;
    final success = _stats['success_rate'] ?? '0%';

    final hud = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KatyaTheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KatyaTheme.primary.withOpacity(0.3)),
        boxShadow: KatyaTheme.spaceShadow,
      ),
      child: _expanded
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub, size: 18, color: KatyaTheme.accent),
                    const SizedBox(width: 6),
                    const Text('Mesh HUD', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _expanded = false),
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Collapse',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _kv('Peers', '$peers'),
                _kv('Queue', '$queue'),
                _kv('Success', '$success'),
                _kv('Restarts', '${_stats['network_restarts'] ?? 0}'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Adapter:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _adapter ?? _adapters.first,
                      items: _adapters
                          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _adapter = v);
                        try {
                          await _mesh.setAdapter(v);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Adapter switched to "$v"')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Switch failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await _mesh.stopMeshNetwork();
                            await _mesh.startMeshNetwork();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mesh restarted')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Restart failed: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart'),
                        style: ElevatedButton.styleFrom(backgroundColor: KatyaTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _screencast ? _stopScreencast : _startScreencast,
                        icon: Icon(_screencast ? Icons.stop_circle_outlined : Icons.movie_creation_outlined),
                        label: Text(_screencast ? 'Stop Screencast' : 'Start Screencast'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            VotingService.instance.clearLocal();
                            await _mesh.clearState();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Demo state cleared')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Clear failed: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.restore_from_trash_outlined),
                        label: const Text('Reset Demo'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub, size: 18, color: KatyaTheme.accent),
                const SizedBox(width: 6),
                Chip(
                  label: Text('peers: $peers • q: $queue • $success'),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _expanded = true),
                  icon: const Icon(Icons.expand_less, size: 18),
                  tooltip: 'Expand',
                ),
              ],
            ),
    );

    return Positioned(
      right: _offset.dx,
      bottom: _offset.dy,
      child: Draggable(
        feedback: Material(color: Colors.transparent, child: hud),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (d) {
          final size = MediaQuery.of(context).size;
          final local = Offset(size.width - d.offset.dx - 100, size.height - d.offset.dy - 100);
          setState(() => _offset = Offset(local.dx.clamp(8, size.width - 160), local.dy.clamp(8, size.height - 160)));
        },
        child: hud,
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(k, style: TextStyle(color: KatyaTheme.onSurface.withOpacity(0.8))))
          ,
          const SizedBox(width: 6),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _startScreencast() {
    setState(() => _screencast = true);
    // Step 1: announce
    _demoTimers.add(Timer(const Duration(milliseconds: 200), () async {
      await _mesh.sendMeshMessage('broadcast', '🎬 Screencast: Mesh is online. Peers ${_stats['connected_peers'] ?? 0}.', type: 'chat');
    }));
    // Step 2: create a demo poll
    _demoTimers.add(Timer(const Duration(seconds: 1), () async {
      try {
        final voting = VotingService.instance;
        await voting.initialize();
        final poll = await voting.createPoll(
          title: 'Demo: Where to meet?',
          description: 'Choose a place for the afterparty.',
          options: const ['Cafe', 'Park', 'Office'],
          creatorId: 'demo',
        );
        // vote one option locally to show counters
        await voting.vote(pollId: poll.id, option: 'Cafe');
      } catch (_) {}
    }));
    // Step 3: send follow-up chat
    _demoTimers.add(Timer(const Duration(seconds: 2), () async {
      await _mesh.sendMeshMessage('broadcast', '📣 Vote created. Cast your vote now!', type: 'chat');
    }));
    // Step 4: wrap up
    _demoTimers.add(Timer(const Duration(seconds: 4), () async {
      await _mesh.sendMeshMessage('broadcast', '✅ Screencast complete.', type: 'chat');
      if (mounted) setState(() => _screencast = false);
    }));
  }

  void _stopScreencast() {
    for (final t in _demoTimers) {
      t.cancel();
    }
    _demoTimers.clear();
    if (mounted) setState(() => _screencast = false);
  }
}


