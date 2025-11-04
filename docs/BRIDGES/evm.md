# EVM Bridge (Design)

Goals:
- Offline-sign transactions, propagate via Mesh, submit when online
- Support EIP-1559, ERC-20/721 transfers

Plan:
- Dart tx builder + RLP encoder, secp256k1 signing (native or pure Dart)
- Nonce management with optimistic queue and conflict resolution
- Mesh message schema for tx + receipts propagation
