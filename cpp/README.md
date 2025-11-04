# Katya Mesh C++ Implementation 🚀

High-performance C++ implementations for Katya AI REChain Mesh network.

## Features

- **mesh-broker-cpp** - High-performance mesh broker service
- **mesh-crypto-cpp** - Native crypto library (X25519, AES-GCM)
- **mesh-discovery-cpp** - UDP/BLE peer discovery
- **mesh-protocol-cpp** - Protocol implementation
- **CMake build system** - Cross-platform builds

## Requirements

- C++17 or later
- CMake 3.15+
- OpenSSL (for crypto)
- Boost (for networking)

## Build

```bash
cd cpp
mkdir build && cd build
cmake ..
make -j$(nproc)

# Or with Ninja
cmake -GNinja ..
ninja
```

## Usage

```bash
# Run broker
./bin/mesh-broker-cpp --port 8081 --adapter emulated

# Run CLI
./bin/meshctl-cpp peers
./bin/meshctl-cpp send --to broadcast --message "Hello from C++!"
```

## Structure

```
cpp/
├── src/
│   ├── broker/        # Broker implementation
│   ├── crypto/        # Crypto library
│   ├── discovery/     # Peer discovery
│   ├── protocol/      # Protocol types
│   └── utils/         # Utilities
├── include/            # Header files
├── tests/              # Unit tests
├── CMakeLists.txt      # CMake config
└── README.md
```

