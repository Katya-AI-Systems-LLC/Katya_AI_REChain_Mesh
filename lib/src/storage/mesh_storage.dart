import 'dart:async';
import 'package:hive/hive.dart';

class StoredNode {
  final String id;
  final String publicKey;
  final String status;
  final DateTime updatedAt;

  StoredNode({required this.id, required this.publicKey, required this.status, required this.updatedAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'publicKey': publicKey,
        'status': status,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static StoredNode fromMap(Map map) => StoredNode(
        id: map['id'] as String,
        publicKey: map['publicKey'] as String,
        status: map['status'] as String,
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class StoredMessage {
  final String id;
  final String fromId;
  final String toId;
  final String payload;
  final DateTime timestamp;
  final int version;

  StoredMessage({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.payload,
    required this.timestamp,
    required this.version,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fromId': fromId,
        'toId': toId,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'version': version,
      };

  static StoredMessage fromMap(Map map) => StoredMessage(
        id: map['id'] as String,
        fromId: map['fromId'] as String,
        toId: map['toId'] as String,
        payload: map['payload'] as String,
        timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
        version: (map['version'] as int?) ?? 0,
      );
}

class MeshStorage {
  static const _nodesBox = 'mesh_nodes';
  static const _messagesBox = 'mesh_messages';

  Box? _nodes;
  Box? _messages;

  Future<void> initialize() async {
    _nodes = await Hive.openBox(_nodesBox);
    _messages = await Hive.openBox(_messagesBox);
  }

  Future<void> putNode(StoredNode node) async {
    final raw = _nodes!.get(node.id) as Map?;
    if (raw == null) {
      await _nodes!.put(node.id, node.toMap());
      return;
    }
    final existing = StoredNode.fromMap(raw);
    if (existing.updatedAt.isBefore(node.updatedAt)) {
      await _nodes!.put(node.id, node.toMap());
    }
  }

  StoredNode? getNode(String id) {
    final raw = _nodes!.get(id) as Map?;
    return raw == null ? null : StoredNode.fromMap(raw);
  }

  Future<void> putMessage(StoredMessage m) async {
    final raw = _messages!.get(m.id) as Map?;
    if (raw == null) {
      await _messages!.put(m.id, m.toMap());
      return;
    }
    final existing = StoredMessage.fromMap(raw);
    final shouldWrite = m.version > existing.version ||
        (m.version == existing.version && m.timestamp.isAfter(existing.timestamp));
    if (shouldWrite) {
      await _messages!.put(m.id, m.toMap());
    }
  }

  List<StoredMessage> listMessages({String? withPeerId}) {
    final all = _messages!.values
        .map((e) => StoredMessage.fromMap((e as Map)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (withPeerId == null) return all;
    return all.where((m) => m.fromId == withPeerId || m.toId == withPeerId).toList();
  }

  Future<void> syncFromPeers(
    Future<List<StoredMessage>> Function() fetchRemoteMessages,
    Future<List<StoredNode>> Function() fetchRemoteNodes,
  ) async {
    final remoteNodes = await fetchRemoteNodes();
    for (final n in remoteNodes) {
      await putNode(n);
    }
    final remoteMsgs = await fetchRemoteMessages();
    for (final m in remoteMsgs) {
      await putMessage(m);
    }
  }

  Future<void> mergeCrdt(List<StoredMessage> incoming) async {
    for (final m in incoming) {
      await putMessage(m);
    }
  }
}
