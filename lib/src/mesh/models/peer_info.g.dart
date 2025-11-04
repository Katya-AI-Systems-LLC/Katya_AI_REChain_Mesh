// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeerInfo _$PeerInfoFromJson(Map<String, dynamic> json) => $checkedCreate(
      'PeerInfo',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['id', 'name'],
        );
        final val = PeerInfo(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          deviceType:
              $checkedConvert('deviceType', (v) => v as String? ?? 'unknown'),
          signalStrength: $checkedConvert(
              'signalStrength', (v) => (v as num?)?.toInt() ?? 0),
          lastSeen: $checkedConvert('last_seen',
              (v) => PeerInfo._dateTimeFromJson((v as num).toInt())),
          supportedProtocols: $checkedConvert(
              'supported_protocols',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  []),
        );
        return val;
      },
      fieldKeyMap: const {
        'lastSeen': 'last_seen',
        'supportedProtocols': 'supported_protocols'
      },
    );

Map<String, dynamic> _$PeerInfoToJson(PeerInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'deviceType': instance.deviceType,
      'signalStrength': instance.signalStrength,
      'last_seen': PeerInfo._dateTimeToJson(instance.lastSeen),
      'supported_protocols': instance.supportedProtocols,
    };
