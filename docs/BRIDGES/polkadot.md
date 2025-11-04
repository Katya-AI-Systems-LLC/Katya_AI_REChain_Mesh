# Polkadot Bridge (Design)

Goals:
- Encode transactions offline, gossip via Mesh, submit when online
- Support Substrate SCALE codec, SS58 addresses

Plan:
- Dart adapter defines tx structs and SCALE encoder
- Optional native plugin for crypto (sr25519/ed25519)
- Queue transactions in Mesh with priority/high QoS
