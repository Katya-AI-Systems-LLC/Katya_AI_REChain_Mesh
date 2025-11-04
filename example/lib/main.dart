import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/katya_ai_rechain_mesh.dart';

void main() {
  runApp(const MeshDemoApp());
}

class MeshDemoApp extends StatelessWidget {
  const MeshDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katya AI REChain Mesh Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MeshDemoPage(),
    );
  }
}

class MeshDemoPage extends StatefulWidget {
  const MeshDemoPage({super.key});

  @override
  State<MeshDemoPage> createState() => _MeshDemoPageState();
}

class _MeshDemoPageState extends State<MeshDemoPage> {
  final BasicMeshService _meshService = BasicMeshService.instance;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _logs = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _setupMeshService();
  }

  @override
  void dispose() {
    _meshService.stop();
    _messageController.dispose();
    super.dispose();
  }

  void _setupMeshService() {
    // Listen for peer discovery events
    _meshService.onPeerDiscovered.listen((peer) {
      _addLog('Discovered peer: ${peer.name} (${peer.id})');
    });

    // Listen for incoming messages
    _meshService.onMessageReceived.listen((message) {
      _addLog('Message from ${message.senderId}: ${message.content}');
    });
  }

  Future<void> _toggleMeshService() async {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      await _meshService.start();
      _addLog('Mesh service started. Node ID: ${_meshService.nodeId}');
    } else {
      await _meshService.stop();
      _addLog('Mesh service stopped');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if (!_isRunning) {
      _addLog('Error: Mesh service is not running');
      return;
    }

    // Broadcast the message to all connected peers
    await _meshService.broadcast(message);
    _addLog('Broadcast: $message');
    
    _messageController.clear();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal()}: $message');
      // Keep only the last 100 logs
      if (_logs.length > 100) {
        _logs.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katya AI REChain Mesh Demo'),
        actions: [
          IconButton(
            icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleMeshService,
            tooltip: _isRunning ? 'Stop Mesh Service' : 'Start Mesh Service',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.all(8.0),
            color: _isRunning ? Colors.green[100] : Colors.red[100],
            child: Row(
              children: [
                Icon(
                  _isRunning ? Icons.check_circle : Icons.error_outline,
                  color: _isRunning ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8.0),
                Text(
                  _isRunning 
                      ? 'Mesh Service: RUNNING (Node ID: ${_meshService.nodeId})' 
                      : 'Mesh Service: STOPPED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isRunning ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                const Spacer(),
                Text(
                  'Peers: ${_meshService.connectedPeers.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message to broadcast',
                      border: OutlineInputBorder(),
                    ),
                    enabled: _isRunning,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _isRunning ? _sendMessage : null,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
          
          // Connected peers list
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Connected Peers', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: _meshService.connectedPeers.isEmpty
                ? const Center(child: Text('No peers connected'))
                : ListView.builder(
                    itemCount: _meshService.connectedPeers.length,
                    itemBuilder: (context, index) {
                      final peer = _meshService.connectedPeers[index];
                      return ListTile(
                        leading: const Icon(Icons.device_hub),
                        title: Text(peer.name),
                        subtitle: Text('ID: ${peer.id}\nType: ${peer.type}'),
                        trailing: Text(
                          '${(peer.signalStrength * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: peer.signalStrength > 0.7 
                                ? Colors.green 
                                : peer.signalStrength > 0.4 
                                    ? Colors.orange 
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Logs
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Text('Logs', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[100],
              child: _logs.isEmpty
                  ? const Center(child: Text('No logs yet'))
                  : ListView.builder(
                      reverse: true,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            _logs[_logs.length - 1 - index],
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
