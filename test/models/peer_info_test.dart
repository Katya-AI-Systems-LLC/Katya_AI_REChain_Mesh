import 'package:flutter_test/flutter_test.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/models/peer_info.dart';

void main() {
  group('PeerInfo', () {
    const testId = 'test-peer-id';
    const testName = 'Test Peer';
    const testDeviceType = 'mobile';
    const testSignalStrength = 75;
    final testLastSeen = DateTime(2023, 1, 1, 12, 0, 0).toUtc();
    const testSupportedProtocols = ['ble', 'wifi'];

    test('should create PeerInfo with required fields', () {
      final peer = PeerInfo(
        id: testId,
        name: testName,
      );

      expect(peer.id, testId);
      expect(peer.name, testName);
      expect(peer.deviceType, 'unknown');
      expect(peer.signalStrength, 0);
      expect(peer.supportedProtocols, isEmpty);
      expect(peer.lastSeen, isNotNull);
    });

    test('should create PeerInfo with all fields', () {
      final peer = PeerInfo(
        id: testId,
        name: testName,
        deviceType: testDeviceType,
        signalStrength: testSignalStrength,
        lastSeen: testLastSeen,
        supportedProtocols: testSupportedProtocols,
      );

      expect(peer.id, testId);
      expect(peer.name, testName);
      expect(peer.deviceType, testDeviceType);
      expect(peer.signalStrength, testSignalStrength);
      expect(peer.lastSeen, testLastSeen);
      expect(peer.supportedProtocols, testSupportedProtocols);
    });

    test('should serialize to JSON correctly', () {
      final peer = PeerInfo(
        id: testId,
        name: testName,
        deviceType: testDeviceType,
        signalStrength: testSignalStrength,
        lastSeen: testLastSeen,
        supportedProtocols: testSupportedProtocols,
      );

      final json = peer.toJson();

      expect(json['id'], testId);
      expect(json['name'], testName);
      expect(json['deviceType'], testDeviceType);
      expect(json['signalStrength'], testSignalStrength);
      expect(json['last_seen'], testLastSeen.millisecondsSinceEpoch);
      expect(json['supported_protocols'], testSupportedProtocols);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': testId,
        'name': testName,
        'deviceType': testDeviceType,
        'signalStrength': testSignalStrength,
        'last_seen': testLastSeen.millisecondsSinceEpoch,
        'supported_protocols': testSupportedProtocols,
      };

      final peer = PeerInfo.fromJson(json);

      expect(peer.id, testId);
      expect(peer.name, testName);
      expect(peer.deviceType, testDeviceType);
      expect(peer.signalStrength, testSignalStrength);
      expect(peer.lastSeen, testLastSeen);
      expect(peer.supportedProtocols, testSupportedProtocols);
    });

    test('should handle JSON string serialization', () {
      final peer = PeerInfo(
        id: testId,
        name: testName,
        deviceType: testDeviceType,
      );

      final jsonString = peer.toJsonString();
      final deserializedPeer = PeerInfo.fromJsonString(jsonString);

      expect(deserializedPeer.id, peer.id);
      expect(deserializedPeer.name, peer.name);
      expect(deserializedPeer.deviceType, peer.deviceType);
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = PeerInfo(
        id: testId,
        name: testName,
        deviceType: testDeviceType,
        signalStrength: testSignalStrength,
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        signalStrength: 90,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Updated Name');
      expect(updated.deviceType, original.deviceType);
      expect(updated.signalStrength, 90);
      expect(updated.lastSeen, original.lastSeen);
    });

    test('copyWith should not modify original instance', () {
      final original = PeerInfo(
        id: testId,
        name: testName,
      );

      original.copyWith(name: 'New Name');

      expect(original.name, testName);
    });

    test('equality should work correctly', () {
      final peer1 = PeerInfo(
        id: testId,
        name: testName,
        deviceType: testDeviceType,
        signalStrength: testSignalStrength,
        lastSeen: testLastSeen,
      );

      final peer2 = PeerInfo(
        id: testId,
        name: testName,
        deviceType: testDeviceType,
        signalStrength: testSignalStrength,
        lastSeen: testLastSeen,
      );

      final peer3 = PeerInfo(
        id: 'different-id',
        name: testName,
        deviceType: testDeviceType,
        signalStrength: testSignalStrength,
        lastSeen: testLastSeen,
      );

      expect(peer1, peer2);
      expect(peer1, isNot(peer3));
    });

    test('hashCode should be consistent with equality', () {
      final peer1 = PeerInfo(
        id: testId,
        name: testName,
      );

      final peer2 = PeerInfo(
        id: testId,
        name: testName,
      );

      expect(peer1.hashCode, peer2.hashCode);
    });

    test('should handle null values in JSON deserialization', () {
      final json = {
        'id': testId,
        'name': testName,
        'last_seen': DateTime.now().millisecondsSinceEpoch,
        // Omitting optional fields
      };

      final peer = PeerInfo.fromJson(json);

      expect(peer.id, testId);
      expect(peer.name, testName);
      expect(peer.deviceType, 'unknown');
      expect(peer.signalStrength, 0);
      expect(peer.supportedProtocols, isEmpty);
    });
  });
}
