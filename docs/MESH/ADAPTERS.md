# Mesh Adapter Abstraction

- Goal: hide platform-specific BLE/Wi-Fi Direct differences behind `MeshAdapter` interface
- Implementations: Android BLE, iOS CoreBluetooth, Desktop mock, Aurora/HarmonyOS stubs
- Responsibilities: scan, advertise, connect, send, receive, health-check

Proposed Dart interface:
- `Future<void> startScan()`
- `Future<void> stopScan()`
- `Stream<MeshPeer> peers`
- `Future<void> send(MeshMessage msg)`
