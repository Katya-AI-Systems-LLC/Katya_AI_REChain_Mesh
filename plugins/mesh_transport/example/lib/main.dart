import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mesh_transport/mesh_transport.dart';

void main() {
  runApp(const MeshTransportExampleApp());
}

class MeshTransportExampleApp extends StatefulWidget {
  const MeshTransportExampleApp({super.key});

  @override
  State<MeshTransportExampleApp> createState() => _MeshTransportExampleAppState();
}

class _MeshTransportExampleAppState extends State<MeshTransportExampleApp> {
  final List<MeshPeer> _peers = [];
  final List<String> _logs = [];
  StreamSubscription? _peerSub;
  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    _peerSub = MeshTransport.peers.listen((p) {
      setState(() => _peers.add(p));
    });
    _msgSub = MeshTransport.messages.listen((m) {
      setState(() => _logs.add('msg from ${m['fromId']}: ${m['data']}'));
    });
  }

  @override
  void dispose() {
    _peerSub?.cancel();
    _msgSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('mesh_transport example')),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => MeshTransport.discover(), child: const Text('Discover')),
                ElevatedButton(onPressed: () => MeshTransport.stopDiscover(), child: const Text('Stop')),
                ElevatedButton(onPressed: () => MeshTransport.advertise('Example'), child: const Text('Advertise')),
                ElevatedButton(onPressed: () => MeshTransport.stopAdvertise(), child: const Text('Stop Adv')),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _peers.length,
                itemBuilder: (ctx, i) {
                  final p = _peers[i];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('${p.id}  rssi=${p.rssi}')
                  );
                },
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (ctx, i) => ListTile(title: Text(_logs[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

