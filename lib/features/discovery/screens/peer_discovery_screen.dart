import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/mesh_service.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/mesh_service_impl.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/models/peer_info.dart';
import 'package:katya_ai_rechain_mesh/features/chat/screens/mesh_chat_screen.dart';

class PeerDiscoveryScreen extends StatefulWidget {
  final MeshService meshService;

  const PeerDiscoveryScreen({
    super.key,
    required this.meshService,
  });

  @override
  _PeerDiscoveryScreenState createState() => _PeerDiscoveryScreenState();
}

class _PeerDiscoveryScreenState extends State<PeerDiscoveryScreen> {
  bool _isDiscovering = false;
  final List<PeerInfo> _discoveredPeers = [];
  late StreamSubscription<PeerInfo> _peerSubscription;
  late StreamSubscription<MeshConnectionState> _connectionSubscription;
  MeshConnectionState _connectionState = MeshConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _initializeMeshService();
  }

  @override
  void dispose() {
    _peerSubscription.cancel();
    _connectionSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeMeshService() async {
    try {
      await widget.meshService.initialize();
      await widget.meshService.startAdvertising();
      
      _connectionSubscription = widget.meshService.connectionStateStream.listen((state) {
        setState(() {
          _connectionState = state;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize mesh service: $e')),
      );
    }
  }

  Future<void> _startDiscovery() async {
    if (_isDiscovering) return;

    setState(() {
      _isDiscovering = true;
      _discoveredPeers.clear();
    });

    try {
      _peerSubscription = widget.meshService.discoverPeers().listen((peer) {
        setState(() {
          final index = _discoveredPeers.indexWhere((p) => p.id == peer.id);
          if (index >= 0) {
            _discoveredPeers[index] = peer;
          } else {
            _discoveredPeers.add(peer);
          }
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to discover peers: $e')),
      );
      setState(() => _isDiscovering = false);
    }
  }

  Future<void> _stopDiscovery() async {
    if (!_isDiscovering) return;

    try {
      await widget.meshService.stopDiscovery();
      await _peerSubscription.cancel();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping discovery: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDiscovering = false);
      }
    }
  }

  String _getConnectionStatus() {
    switch (_connectionState) {
      case MeshConnectionState.connected:
        return 'Connected';
      case MeshConnectionState.connecting:
        return 'Connecting...';
      case MeshConnectionState.disconnected:
        return 'Disconnected';
      case MeshConnectionState.error:
        return 'Error';
      case MeshConnectionState.advertising:
        return 'Advertising';
      case MeshConnectionState.discovering:
        return 'Discovering';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Peers'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: _connectionState == MeshConnectionState.connected
                      ? Colors.green
                      : Colors.orange,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Text(_getConnectionStatus()),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isDiscovering ? Icons.stop : Icons.search),
                  label: Text(_isDiscovering ? 'Stop Discovery' : 'Discover Peers'),
                  onPressed: _isDiscovering ? _stopDiscovery : _startDiscovery,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_discoveredPeers.length} devices found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isDiscovering && _discoveredPeers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildPeerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerList() {
    if (_discoveredPeers.isEmpty) {
      return const Center(
        child: Text('No peers found. Tap "Discover Peers" to start searching.'),
      );
    }

    return ListView.builder(
      itemCount: _discoveredPeers.length,
      itemBuilder: (context, index) {
        final peer = _discoveredPeers[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(peer.name),
          subtitle: Text('Signal: ${peer.signalStrength}%'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _connectToPeer(peer),
        );
      },
    );
  }

  void _connectToPeer(PeerInfo peer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeshChatScreen(
          peerId: peer.id,
          peerName: peer.name,
          meshService: widget.meshService,
        ),
      ),
    );
  }
}
