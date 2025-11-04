// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mesh_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeshMessage _$MeshMessageFromJson(Map<String, dynamic> json) => $checkedCreate(
      'MeshMessage',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['id', 'sender_id', 'type'],
        );
        final val = MeshMessage(
          id: $checkedConvert('id', (v) => v as String),
          senderId: $checkedConvert('sender_id', (v) => v as String),
          recipientIds: $checkedConvert(
              'recipient_ids',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  []),
          type: $checkedConvert(
              'type', (v) => $enumDecode(_$MessageTypeEnumMap, v)),
          text: $checkedConvert('text', (v) => v as String?),
          binaryData: $checkedConvert(
              'binary_data', (v) => _base64Decode(v as String?)),
          timestamp: $checkedConvert(
              'timestamp', (v) => _dateTimeFromJson((v as num).toInt())),
          ttl: $checkedConvert('ttl', (v) => (v as num?)?.toInt() ?? 10),
          priority:
              $checkedConvert('priority', (v) => (v as num?)?.toInt() ?? 5),
          metadata:
              $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
        );
        return val;
      },
      fieldKeyMap: const {
        'senderId': 'sender_id',
        'recipientIds': 'recipient_ids',
        'binaryData': 'binary_data'
      },
    );

Map<String, dynamic> _$MeshMessageToJson(MeshMessage instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'sender_id': instance.senderId,
    'recipient_ids': instance.recipientIds,
    'type': _$MessageTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('text', instance.text);
  writeNotNull('binary_data', _base64Encode(instance.binaryData));
  val['timestamp'] = _dateTimeToJson(instance.timestamp);
  val['ttl'] = instance.ttl;
  val['priority'] = instance.priority;
  writeNotNull('metadata', instance.metadata);
  return val;
}

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.binary: 'binary',
  MessageType.command: 'command',
  MessageType.ack: 'ack',
  MessageType.error: 'error',
  MessageType.discovery: 'discovery',
  MessageType.routing: 'routing',
  MessageType.chat: 'chat',
  MessageType.vote: 'vote',
  MessageType.file: 'file',
};
