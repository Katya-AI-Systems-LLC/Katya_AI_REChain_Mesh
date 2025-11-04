import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fromId;

  @HiveField(2)
  final String toId;

  @HiveField(3)
  final String body;

  @HiveField(4)
  final DateTime ts;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final bool encrypted;

  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.body,
    required this.ts,
    this.status = 'sent',
    this.encrypted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromId': fromId,
      'toId': toId,
      'body': body,
      'ts': ts.toIso8601String(),
      'status': status,
      'encrypted': encrypted,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      fromId: json['fromId'],
      toId: json['toId'],
      body: json['body'],
      ts: DateTime.parse(json['ts']),
      status: json['status'] ?? 'sent',
      encrypted: json['encrypted'] ?? false,
    );
  }

  Message copyWith({
    String? id,
    String? fromId,
    String? toId,
    String? body,
    DateTime? ts,
    String? status,
    bool? encrypted,
  }) {
    return Message(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      body: body ?? this.body,
      ts: ts ?? this.ts,
      status: status ?? this.status,
      encrypted: encrypted ?? this.encrypted,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, fromId: $fromId, toId: $toId, body: $body, ts: $ts, status: $status, encrypted: $encrypted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
