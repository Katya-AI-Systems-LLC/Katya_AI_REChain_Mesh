# Katya Mesh Quantum App 🚀

[![Build Status](https://github.com/katya/quantum-mesh-app/actions/workflows/flutter_ci_full.yml/badge.svg)](https://github.com/katya/quantum-mesh-app/actions)
[![License](https://img.shields.io/github/license/katya/quantum-mesh-app)](LICENSE)
[![Hackathon](https://img.shields.io/badge/hackathon-Yandex-red)](https://yandex.ru/hackathon)

> **Truly offline, AI-empowered mesh messenger & voting—runs anywhere, even in a bunker!**

---

### 🔥 DEMO / Screencast
[Смотреть демо / Watch on YouTube](https://your-screencast-link)  
See `docs/screens/demo_main.gif` for UI quickpeek.

---

## 🌟 Why Mesh Quantum App?
- **Works without internet:** Bluetooth LE, Nearby, Mesh, Wi-Fi/UDP, even in metro or forests!
- **Instant mesh voting & messenger:** Real group chats and polls — no server needed.
- **On-device or OpenAI agent:** Offline AI assistant; copilot, Q&A, vote explainability.
- **Blockchain-ready:** Hash your votes to Polkadot/Substrate for trust!
- **All platforms:** Android, iOS, Mac, Windows, Linux, Web, Aurora, UWP.

---

## 🚀 Quick Start

### Flutter App
```bash
git clone https://github.com/katya/quantum-mesh-app.git
cd quantum-mesh-app
flutter pub get
flutter run
```

### Go CLI & Services
```bash
cd go
go build -o bin/meshctl ./cmd/meshctl
go build -o bin/mesh-broker ./cmd/mesh-broker

# Use meshctl
./bin/meshctl start --adapter emulated
./bin/meshctl peers
./bin/meshctl send --to broadcast --message "Hello!"
```

### Backend (optional features):
```bash
docker-compose up -d
```

## 🧩 Features
- **Mesh messenger** (BLE/Nearby/Wi-Fi/UDP) — offline chat with broadcast fallback
- **Offline voting** (majority consensus/quorum) — real-time mesh-synchronized polls
- **🤖 AI Assistant Katya** — offline AI with chat suggestions & poll analysis
- **Offline persistence** — Hive storage for chat history
- **Interactive MeshMap** — view of network topology
- **Mesh HUD** — live stats overlay (peers, queue, success rate)
- **Screencast mode** — automated demo sequence
- **Runtime adapter toggle** — switch mesh backends on the fly
- **CLI tools** — Dart (`meshctl`) and **Go** (`go/cmd/meshctl`) implementations
- **Go mesh broker** — standalone mesh network service with **REST API**
- **Go UDP discovery** — multicast peer discovery
- **Go message encryption** — AES-GCM encryption
- **Go state persistence** — JSON storage for messages, polls, votes
- **Go crypto utilities** — X25519 handshake, HKDF key derivation
- **C++ implementation** — High-performance broker and crypto library
- **gRPC API** — High-performance RPC for services
- **WebSocket server** — Real-time updates for clients
- **Prometheus metrics** — Metrics exporter for monitoring
- **Kubernetes deployment** — K8s manifests and ConfigMaps
- **Terraform infrastructure** — AWS EKS and **Yandex Cloud** infrastructure as code
- **CI/CD pipelines** — GitHub Actions for automated testing
- **PostgreSQL integration** — Database storage for messages, polls, votes
- **Redis caching** — Caching and pub/sub for real-time updates
- **Helm charts** — Kubernetes package management
- **Docker Compose** — Local development environment
- **Nginx reverse proxy** — Load balancing and rate limiting
- Secure: End-to-end encryption, blockchain bridge

## 🌍 Mirrors
- [GitHub](https://github.com/katya/quantum-mesh-app)
- [SourceCraft](https://sourcecraft.ru/katya/mesh)
- [GitFlic](https://gitflic.ru/project/katya/mesh)

## 📑 Docs
- [DOCS_INDEX.md](docs/DOCS_INDEX.md)
- [ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [PLATFORMS.md](docs/PLATFORMS.md)
- [SECURITY.md](docs/SECURITY.md)
- [POST_ONLINE_SYNC.md](docs/POST_ONLINE_SYNC.md)
- [AI prompt templates](docs/PROMPTS.md)
- [🌌 Манифест новой цифровой эры](docs/MANIFEST_RU.md)
- [🚀 Пресс-релиз: Quantum Infrastructure Zero](docs/PRESS_RELEASE_RU.md)
- [🌌 Manifest of the New Digital Era (EN)](docs/MANIFEST_EN.md)
- [🚀 Press Release: Quantum Infrastructure Zero (EN)](docs/PRESS_RELEASE_EN.md)
- [**Go Implementation**](go/README.md) - CLI tools, mesh broker, crypto utilities

---

## ⚡ Russian summary (for GitFlic/SourceCraft)
> Mesh Quantum App — это оффлайн-мессенджер и голосовалка с AI, работающий без интернета (BLE, Wi-Fi, Nearby, Voting, AI, Blockchain, CLI на Dart и **Go**, вся документация в /docs/). Участвует в AI-хакатоне Яндекса-2025!

## 🐹 Go Implementation

Полноценная Go-имплементация mesh-утилит:
- **CLI** (`go/cmd/meshctl`) — управление mesh-сетью из командной строки
- **Broker Service** (`go/cmd/mesh-broker`) — standalone mesh-сервис
- **Protocol** (`go/pkg/protocol`) — сообщения и голосования
- **Crypto** (`go/internal/crypto`) — X25519 handshake, HKDF key derivation
- **Mesh** (`go/internal/mesh`) — broker, routing, peer discovery

См. [go/README.md](go/README.md) для деталей.

---

🤝 **PRs welcome! For questions, join [Telegram](https://t.me/katya_mesh)**