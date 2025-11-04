import 'dart:convert';
import 'package:katya_ai_rechain_mesh/src/services/mesh_service_ble.dart';

void main(List<String> args) async {
  final mesh = MeshServiceBLE.instance;
  await mesh.initialize();

  if (args.isEmpty) {
    print('Usage: meshctl <list-peers|ping-peer <id>|send-test <id> <msg>|log-stats> [--format=json]');
    return;
  }

  final cmd = args[0];
  final jsonOut = args.contains('--format=json');

  Future<void> out(Object o) async {
    if (jsonOut) {
      print(jsonEncode(o));
    } else {
      print(o);
    }
  }

  switch (cmd) {
    case 'list-peers':
      final peers = mesh.peers
          .map((p) => {'id': p.id, 'name': p.name, 'rssi': p.rssi})
          .toList();
      await out({'peers': peers});
      break;
    case 'ping-peer':
      if (args.length < 2) {
        print('peer id required');
        return;
      }
      final id = args[1];
      await mesh.sendMeshMessage(id, 'ping', type: 'chat');
      await out({'ok': true, 'peer': id});
      break;
    case 'send-test':
      if (args.length < 3) {
        print('peer id and message required');
        return;
      }
      final id = args[1];
      final msg = args.sublist(2).join(' ');
      await mesh.sendMeshMessage(id, msg, type: 'chat');
      await out({'ok': true, 'peer': id, 'message': msg});
      break;
    case 'log-stats':
      await out(mesh.getMeshStatistics());
      break;
    default:
      print('Unknown command');
  }
}

