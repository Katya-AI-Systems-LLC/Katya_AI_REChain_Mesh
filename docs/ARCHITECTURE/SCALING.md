# Scalable Architecture: Verticals, Horizontals, Bridges

- Verticals: Mesh, Messenger, Voting, Social, Gaming, IoT, Blockchain
- Horizontals: AI/Agents, Security, Storage/Sync, Telemetry, UI/Design System
- Bridges: Chain bridges (Polkadot, EVM), AI bridges (MCP/GPT), CODE+VIBE

Principles:
- Modular services with clear interfaces (Dart services in `lib/src/services`)
- Event-driven (Streams) and offline-first state replication over Mesh
- Platform adapters per target (BLE, file, storage) behind abstractions

Roadmap:
- Extract common messaging bus, add QoS levels, durable queues
- Implement plugin-based bridges (blockchain, AI) with sandboxed adapters
- Introduce background workers per platform for retries and sync
