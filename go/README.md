# Katya Mesh Go Implementation 🚀

Go utilities and services for Katya AI REChain Mesh network.

## Features

- **meshctl** - CLI tool for mesh network management
- **mesh/broker** - Mesh network broker service with REST API
- **UDP discovery** - Multicast peer discovery via UDP
- **Message encryption** - AES-GCM encryption for messages
- **State persistence** - JSON-based storage for messages, polls, votes
- **crypto** - X25519 handshake, HKDF key derivation
- **REST API** - HTTP API for mesh operations

## Requirements

- Go 1.21 or later
- Optional: Make (for `make build`)

## Build

```bash
cd go

# Download dependencies
go mod download

# Build with Make
make build

# Or build manually
go build -o bin/meshctl ./cmd/meshctl
go build -o bin/mesh-broker ./cmd/mesh-broker
```

## Usage

### CLI (meshctl)

```bash
# Start mesh network
./bin/meshctl start --adapter emulated

# List peers
./bin/meshctl peers

# Send message
./bin/meshctl send --to <peer-id> --message "Hello mesh!"

# Create poll
./bin/meshctl poll create --title "Where to meet?" --options "Cafe,Park,Office"

# Vote
./bin/meshctl poll vote --poll-id <id> --option "Cafe"

# Get mesh stats
./bin/meshctl stats
```

### Broker Service with REST API

```bash
# Run broker service with REST API
./bin/mesh-broker --port 8080 --adapter emulated

# API endpoints:
# GET  /health                  - Health check
# GET  /api/v1/peers            - List peers
# POST /api/v1/messages/send    - Send message
# GET  /api/v1/messages         - List messages
# POST /api/v1/polls/create     - Create poll
# POST /api/v1/polls/vote       - Cast vote
# GET  /api/v1/polls            - List polls
# POST /api/v1/polls/analyze    - AI analyze poll
# GET  /api/v1/stats            - Get stats

# Example API calls:
curl http://localhost:8080/health
curl http://localhost:8080/api/v1/peers
curl -X POST http://localhost:8080/api/v1/messages/send \
  -H "Content-Type: application/json" \
  -d '{"to":"broadcast","message":"Hello!"}'
```

## Structure

```
go/
├── cmd/
│   ├── meshctl/        # CLI tool
│   └── mesh-broker/    # Broker service
├── internal/
│   ├── mesh/          # Mesh networking
│   │   ├── broker.go  # Broker implementation
│   │   └── peer.go    # Peer management
│   └── crypto/        # Cryptography
│       ├── handshake.go # X25519 handshake
│       └── keys.go      # Key generation & signing
├── pkg/
│   ├── protocol/      # Mesh protocol
│   │   ├── message.go  # Message types
│   │   └── voting.go  # Voting poll types
│   └── api/           # REST API server
│       └── server.go
├── internal/
│   ├── mesh/          # Mesh networking
│   │   ├── broker.go  # Broker implementation
│   │   ├── peer.go    # Peer management
│   │   └── discovery.go # UDP peer discovery
│   ├── crypto/        # Cryptography
│   │   ├── handshake.go # X25519 handshake
│   │   ├── keys.go      # Key generation & signing
│   │   └── encrypt.go   # AES-GCM encryption
│   └── storage/       # State persistence
│       └── persistence.go
├── examples/          # Example programs
│   ├── simple_chat.go
│   ├── simple_poll.go
│   └── api_client.go  # REST API client example
├── go.mod             # Go module
├── Makefile           # Build automation
└── README.md          # This file
```

## Examples

Run examples:

```bash
# Simple chat example
go run examples/simple_chat.go

# Simple poll example
go run examples/simple_poll.go

# API client example (requires broker running)
./bin/mesh-broker --port 8080 &
go run examples/api_client.go
```

## Testing

```bash
go test ./...
go vet ./...
```

## Docker

Build and run with Docker:

```bash
# Build image
docker build -t katya-mesh-go .

# Run container
docker run -p 8080:8080 katya-mesh-go

# Or use docker-compose
docker-compose up -d
```

## Architecture

- **CLI** (`cmd/meshctl`) - Command-line interface for mesh operations
- **Broker** (`cmd/mesh-broker`) - Standalone mesh service with REST API
- **REST API** (`pkg/api`) - HTTP endpoints for mesh operations
- **Storage** (`internal/storage`) - JSON-based persistence layer
- **UDP Discovery** (`internal/mesh/discovery`) - Multicast peer discovery
- **Crypto** (`internal/crypto`) - X25519 handshake, AES-GCM encryption
- **Protocol** (`pkg/protocol`) - Message and voting types

