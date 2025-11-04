# Cosmos Bridge (Design)

Goals:
- Offline sign (Amino/Protobuf), gossip over Mesh, broadcast when online
- Support IBC packets as payloads for cross-zone messages

Plan:
- Dart protobuf codecs + secp256k1 signing
- Deterministic fee/sequence handling with retries
- Mesh topics per chain-id to reduce noise
