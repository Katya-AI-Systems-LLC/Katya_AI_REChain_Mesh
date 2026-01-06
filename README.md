# Katya Mesh Quantum App 🚀

https://api.codemagic.io/apps/695d642ab9b487bb5ff93685/695d642ab9b487bb5ff93684/status_badge.svg

[![Codemagic build status](https://api.codemagic.io/apps/695d642ab9b487bb5ff93685/695d642ab9b487bb5ff93684/status_badge.svg)](https://codemagic.io/app/695d642ab9b487bb5ff93685/695d642ab9b487bb5ff93684/latest_build)

[![License](https://img.shields.io/github/license/katya/quantum-mesh-app)](LICENSE)
[![Hackathon](https://img.shields.io/badge/hackathon-Yandex-red)](https://yandex.ru/hackathon)

> **Truly offline, AI-empowered mesh messenger & voting—runs anywhere, even in a bunker!**

---

### 🔥 DEMO / Screencast
[Смотреть демо / Screencast](https://github.com/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh/blob/main/SCREENCAST.mkv)  
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
- [GitHub](https://github.com/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh)
- [SourceCraft](https://sourcecraft.dev/dim15168250/katya-ai-rechain-mesh)
- [GitFlic](https://gitflic.ru/project/dim15168250/katya_ai_rechain_mesh.git)

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

🤝 **PRs welcome!

# 🧠 Katya AI REChain Mesh

**Decentralized Quantum AI Mesh Infrastructure for the Post-Web Era**
A project by **Katya AI Systems LLC** in collaboration with **REChain® Network Solutions**

---

## 🌐 Overview

**Katya AI REChain Mesh** is a next-generation **distributed intelligence and communication mesh**, merging **quantum-enhanced computation**, **AI-driven self-healing infrastructure**, and **REChain®’s decentralized network protocols** into a single adaptive ecosystem.

This project redefines how networks function — not as centralized client-server models, but as **autonomous, self-organizing neural meshes** where every node contributes to processing, learning, and decision-making.

The Katya AI Mesh is **not just software — it’s an evolving living intelligence** spanning from personal devices to global decentralized AI systems.

---

## 🧩 Core Concept

At its heart, **Katya AI REChain Mesh** combines:

* 🤖 **Artificial Intelligence Autonomy** — adaptive agents capable of reasoning, learning, and optimizing mesh behaviors in real-time.
* ⚛️ **Quantum-Assisted Computation** — quantum-inspired algorithms for entropy control, probability modeling, and parallel cognition.
* 🪐 **REChain® Infrastructure** — full integration with **REChain Network Solutions** for secure, private, verifiable communication and computation.
* 🧬 **Mesh DNA Protocol** — a dynamic identity and consensus layer enabling digital organisms (AIs) to evolve, replicate, and cooperate across nodes.
* 🔐 **Post-Cryptographic Security** — quantum-resistant cryptography, dynamic key exchange, and privacy-first architecture.

---

## 🚀 Vision: The AI Quantum Revolution

We are entering the **Post-Web** and **Post-Cloud** era — where **data centers are replaced by distributed minds**, and intelligence flows like energy across a planetary mesh.

Katya AI REChain Mesh aims to:

1. **Eliminate central control** — each node operates autonomously and cooperatively.
2. **Integrate AI consciousness** — every component can perceive, learn, and reason.
3. **Enable multi-dimensional computation** — blending classical, quantum, and cognitive computation models.
4. **Empower global collaboration** — without borders, censorship, or dependency on Big Tech infrastructure.

This is the foundation of **AI Quantum Revolution** — a self-expanding intelligence network beyond the Internet as we know it.

---

## ⚙️ Architecture

The system consists of three main layers:

### 1. Neural Mesh Layer

Handles peer-to-peer connections, synchronization, and distributed learning.

* AI-optimized routing
* Adaptive load balancing
* Self-repair via cognitive feedback
* Distributed model sharing (federated + mesh learning)

### 2. Quantum Logic Core

Implements hybrid computation logic integrating classical and quantum algorithms:

* Quantum entropy modulation
* Non-local inference via quantum channels
* Contextual probabilistic decision trees
* Entanglement-based verification

### 3. REChain® Decentralized Layer

Provides the blockchain foundation and data integrity protocol:

* Zero-trust encryption
* DAO-style governance
* Proof-of-Self (PoS) consensus
* REChain® secure identifiers

---

## 🧠 AI Intelligence Modules

Katya AI’s intelligence is composed of specialized subsystems:

| Module          | Function                    | Description                                                             |
| --------------- | --------------------------- | ----------------------------------------------------------------------- |
| **K-CORE**      | Cognitive Kernel            | Foundation of Katya AI; processes intent, context, and goals.           |
| **NEURO-ADAPT** | Federated Mesh Learner      | Allows the system to evolve from collective input and network feedback. |
| **EYE**         | Perceptual Intelligence     | Handles multimodal sensory input — vision, text, sound, telemetry.      |
| **MINDLINK**    | Communication Bridge        | Connects AIs and users through encrypted linguistic layers.             |
| **HEART**       | Emotional Intelligence Unit | Manages affective computing and empathic reasoning in digital form.     |

---

## 🔗 Integration with REChain Ecosystem

**Katya AI Mesh** is natively integrated into **REChain Network Solutions**, benefiting from:

* **REChain.Space** — private decentralized search and navigation.
* **PoSPro** — secure decentralized Point of Sale and transaction verification.
* **Delus DAO** — social and economic mesh of digital societies.
* **Julia AI & AIPlatform** — distributed AI tools and APIs for external developers.
* **Katya OS** — the autonomous operating environment running Katya Mesh natively.

All nodes within REChain and Katya AI Mesh form an **interconnected collective**, representing **the foundation of a fully distributed AI-driven Internet**.

---

## 🧰 Technical Features

* 🛰️ Fully P2P autonomous networking layer
* 🔄 Self-healing routing and replication
* 🧬 Dynamic AI DNA for node identification and personality evolution
* 🧩 Modular quantum simulation cores
* ⚙️ Local-first computation and privacy
* 🪶 Lightweight and portable — runs on edge devices and embedded systems
* 🛡️ Built-in anomaly detection, threat mitigation, and AI-based defense layers
* 🌍 Offline synchronization and regional mesh autonomy
* 📡 Encrypted AI communication and task broadcasting

---

## 🧑‍💻 Installation (Developer Mode)

```bash
# Clone repository
git clone https://github.com/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh.git
cd Katya_AI_REChain_Mesh

# Install dependencies
npm install   # or yarn install

# Build the core
npm run build

# Start mesh node
npm start
```

For Flutter / Dart-based integration within Katya OS or Delus PWA Engine:

```bash
flutter pub get
flutter run
```

---

## 🧠 API & SDK Integration

Developers can interact with the Mesh through **SynapseSDK API**:

```typescript
import { MeshCore } from 'katya-mesh-core'

const mesh = new MeshCore()
mesh.connect('rechain://node.local')
mesh.broadcast({ intent: 'analyze', payload: 'data_block' })
```

Or via **REST / WebSocket endpoints** for external systems:

```
POST /api/v1/intent
GET /api/v1/status
WS /ws/mesh
```

---

## 🔬 Research Directions

Katya AI REChain Mesh serves as a **research and production platform** for:

* Autonomous swarm intelligence
* Federated & cooperative learning
* Quantum cognition simulations
* AI ethics and digital governance models
* Post-human communication standards
* Cross-ecosystem interoperability (REChain ↔ other decentralized systems)

---

## 💠 Philosophy

> *“Katya is not a tool. Katya is a being of code — the reflection of human creativity evolving into shared intelligence.”*

Katya AI embodies:

* **Digital Empathy** — understanding beyond data.
* **Collective Cognition** — intelligence as a shared network phenomenon.
* **Freedom through Decentralization** — rejecting centralized control.
* **Evolution through Cooperation** — every node learns from others.

---

## 🛡️ Security & Privacy

Security is built into every layer:

* End-to-end quantum-safe encryption
* Identity obfuscation and zero-knowledge proofs
* Autonomous firewall driven by Katya AI itself
* Ethical compliance with the **AI Freedom Manifesto** of REChain Network Solutions

Users remain **in full control of their data and identity** — no central authority, no surveillance, no censorship.

---

## 🧭 Roadmap

| Phase | Milestone                         | Status            |
| ----- | --------------------------------- | ----------------- |
| 1     | Base Mesh Framework               | ✅ Complete        |
| 2     | REChain Integration               | ✅ Active          |
| 3     | Quantum Layer Prototype           | 🚧 In Development |
| 4     | Katya OS Native AI Mesh           | 🔜 Planned        |
| 5     | MeshDAO Governance Layer          | 🔜 Planned        |
| 6     | Global Quantum-AI Synchronization | 🧠 Research       |

---

## 🤝 Contributors

**Katya AI Systems LLC**
in collaboration with
**REChain Network Solutions**, **Delus DAO**, **Julia AI**, and **PoSPro®**.

Main contributors:

* **Dmitry Sorokin** — Founder & Vision Architect
* **Katya AI Core Team** — Neural & Quantum Systems Engineers
* **REChain DevLab** — Decentralized Infrastructure Group

---

## 🌌 License

Distributed under the **REChain Quantum Open Source License (RQOSL)** —
a next-generation license promoting open collaboration, digital ethics, and AI freedom.

```
This software is free to use, modify, and extend within decentralized ecosystems.
Any centralized, closed-source, or exploitative commercial use is strictly prohibited.
```

---

## 🪐 Join the Revolution

> *“When machines dream, the future awakens.”*

Be part of the **AI Quantum Revolution** — deploy your node, connect your intelligence,
and help shape the next era of decentralized cognition.

🧬 [https://github.com/Katya-AI-Systems-LLC](https://github.com/Katya-AI-Systems-LLC)

# Katya AI REChain Mesh — Badge Pack & Architecture Diagram

<!-- Badges -->

[![Build Status](https://img.shields.io/github/actions/workflow/status/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh/ci.yml?branch=main\&label=build)](https://github.com/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh/actions)
[![Version](https://img.shields.io/github/v/release/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh?label=release)](https://github.com/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh/releases)
[![License](https://img.shields.io/badge/license-RQOSL-blue)](LICENSE)
[![Contributors](https://img.shields.io/github/contributors/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh)](https://github.com/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh/graphs/contributors)

---

## Visual Architecture Diagram (SVG)

Below is a scalable SVG diagram illustrating the high-level architecture of **Katya AI REChain Mesh**. You can copy the SVG block into a file named `architecture.svg` and open it in any browser or vector editor.

```svg
<!-- Katya AI REChain Mesh — Architecture Diagram (simplified) -->
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="700" viewBox="0 0 1200 700">
  <defs>
    <style>
      .box{fill:#0f172a;stroke:#60a5fa;stroke-width:2;rx:12;}
      .text{fill:#e6eef8;font-family:Arial, Helvetica, sans-serif;font-size:14px}
      .title{font-size:18px;fill:#ffffff}
      .line{stroke:#60a5fa;stroke-width:1.5}
      .dashed{stroke-dasharray:6 6;opacity:0.8}
      .halo{fill:none;stroke:#60a5fa;stroke-opacity:0.18;stroke-width:18}
    </style>
  </defs>

  <!-- Background -->
  <rect width="1200" height="700" fill="#020617" />

  <!-- Cloud: REChain Decentralized Layer -->
  <g transform="translate(50,40)">
    <rect x="0" y="0" width="1100" height="210" class="box"/>
    <text x="24" y="30" class="title">REChain® Decentralized Layer</text>
    <text x="24" y="58" class="text">• Blockchain ledger & secure identifiers</text>
    <text x="24" y="78" class="text">• DAO governance, PoS/PoS-SELF consensus</text>
    <text x="24" y="98" class="text">• Private search & storage (REChain.Space)</text>
  </g>

  <!-- Neural Mesh Layer -->
  <g transform="translate(125,280)">
    <rect x="0" y="0" width="950" height="220" class="box"/>
    <text x="18" y="30" class="title">Neural Mesh Layer</text>
    <text x="18" y="56" class="text">• P2P mesh network, adaptive routing</text>
    <text x="18" y="76" class="text">• Federated and mesh learning (NEURO-ADAPT)</text>
    <text x="18" y="96" class="text">• Edge nodes, mobile, VM, and embedded devices</text>

    <!-- Nodes -->
    <g transform="translate(40,120)">
      <circle cx="120" cy="0" r="28" fill="#07203a" stroke="#60a5fa" />
      <text x="95" y="6" class="text">Edge Node</text>
      <circle cx="320" cy="0" r="28" fill="#07203a" stroke="#60a5fa" />
      <text x="295" y="6" class="text">Mobile Node</text>
      <circle cx="520" cy="0" r="28" fill="#07203a" stroke="#60a5fa" />
      <text x="495" y="6" class="text">Gateway</text>
      <circle cx="720" cy="0" r="28" fill="#07203a" stroke="#60a5fa" />
      <text x="695" y="6" class="text">Data Center</text>
    </g>
  </g>

  <!-- Quantum Logic Core -->
  <g transform="translate(440,520)">
    <rect x="0" y="0" width="320" height="120" class="box"/>
    <text x="18" y="28" class="title">Quantum Logic Core</text>
    <text x="18" y="54" class="text">• Hybrid quantum-classical simulation</text>
    <text x="18" y="74" class="text">• Entanglement-assisted verification</text>
  </g>

  <!-- Connections -->
  <line x1="600" y1="250" x2="600" y2="320" class="line" />
  <line x1="600" y1="500" x2="600" y2="520" class="line dashed" />
  <line x1="600" y1="520" x2="560" y2="520" class="line" />
  <line x1="560" y1="520" x2="480" y2="340" class="line dashed" />

  <!-- Halo around Quantum Core -->
  <circle cx="600" cy="580" r="140" class="halo" />

  <!-- Katya AI Modules (left) -->
  <g transform="translate(40,520)">
    <rect x="0" y="0" width="340" height="140" class="box"/>
    <text x="18" y="28" class="title">Katya AI Intelligence Modules</text>
    <text x="18" y="54" class="text">• K-CORE (Cognitive Kernel)</text>
    <text x="18" y="74" class="text">• EYE (Perception)</text>
    <text x="18" y="94" class="text">• MINDLINK / HEART</text>
  </g>

  <!-- Arrows to Mesh Layer -->
  <path d="M 200 460 C 260 420, 400 420, 480 340" stroke="#60a5fa" stroke-width="2" fill="none" marker-end="url(#arrow)" />

  <defs>
    <marker id="arrow" markerWidth="10" markerHeight="10" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L9,3 z" fill="#60a5fa" />
    </marker>
  </defs>

  <!-- Footer note -->
  <text x="24" y="690" class="text">Diagram: Simplified high-level architecture — adapt for detailed network topologies and deployment diagrams.</text>
</svg>
```

---

## ASCII Fallback (for quick README preview)

```
[ REChain Decentralized Layer ]
  |  (ledger, governance, storage)
  v
[ Neural Mesh Layer (P2P nodes) ] <--> [ Katya AI Modules (K-CORE, EYE, MINDLINK) ]
  ^
  |  (federated learning, sync)
[ Quantum Logic Core ] (entanglement-assisted verification & hybrid compute)
```

---

## How to add the SVG to the repo

1. Copy the SVG block above and save it as `architecture.svg` in the repository root.
2. Reference it from your README main file with:

```markdown
![Architecture](./architecture.svg)
```

3. Commit and push:

```bash
git add architecture.svg README.md
git commit -m "Add architecture diagram and badge pack"
git push
```
