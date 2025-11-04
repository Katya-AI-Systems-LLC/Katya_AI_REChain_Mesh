# Katya Mesh Testing Guide

This guide covers comprehensive testing for the Katya AI REChain Mesh project across all implementations (Go, C++, C, Rust).

## Table of Contents

- [Quick Start](#quick-start)
- [Test Categories](#test-categories)
- [Running Tests](#running-tests)
- [Cross-Language Interoperability](#cross-language-interoperability)
- [Performance Benchmarking](#performance-benchmarking)
- [Security Testing](#security-testing)
- [Platform Compatibility](#platform-compatibility)
- [CI/CD Integration](#cicd-integration)
- [Test Results Analysis](#test-results-analysis)

## Quick Start

### Prerequisites

```bash
# Install Go 1.21+
go version

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install C++ dependencies
sudo apt-get install build-essential cmake libssl-dev libboost-all-dev

# Install Python for benchmark comparison
pip install matplotlib numpy
```

### Run All Tests

```bash
# From project root
make test-all

# Or run individually
make test-go
make test-cpp
make test-c
make test-rust
```

## Test Categories

### 1. Unit Tests
- **Go**: `go test ./...`
- **C++**: `ctest` (Google Test framework)
- **C**: Custom test runner
- **Rust**: `cargo test`

### 2. Integration Tests
- Cross-language interoperability
- Network communication
- Database operations
- External service integration

### 3. Performance Benchmarks
- Message throughput
- Crypto operations
- Memory usage
- CPU utilization

### 4. Security Tests
- Encryption/decryption validation
- Key exchange verification
- Replay attack protection
- Memory safety checks

### 5. Platform Compatibility
- OS-specific functionality
- Architecture support
- File system operations
- Network interface detection

## Running Tests

### Go Tests

```bash
cd go
go test -v ./...
go test -bench=. -benchmem ./...
```

### C++ Tests

```bash
cd cpp
mkdir build && cd build
cmake .. -DBUILD_TESTS=ON
make
ctest -V
```

### C Tests

```bash
cd c
make test
./build/c_test
```

### Rust Tests

```bash
cd rust
cargo test
cargo bench
```

### Cross-Language Tests

```bash
# Run interoperability tests
go test ./tests/interop/...

# Run with multiple implementations
make test-interop
```

## Cross-Language Interoperability

### Test Setup

1. **Start nodes in different languages**:

```bash
# Terminal 1: Go node
cd go && go run examples/simple_chat.go --port 8080

# Terminal 2: C++ node
cd cpp/build && ./mesh-broker-cpp --port 8081

# Terminal 3: C node
cd c/build && ./mesh-broker-c --port 8082

# Terminal 4: Rust node
cd rust && cargo run --bin node -- --port 8083
```

2. **Run interoperability tests**:

```bash
go test ./tests/interop/cross_lang_test.go -v
```

### Expected Results

- All nodes should discover each other
- Messages should be exchanged successfully
- Encryption should work across languages
- Performance should be consistent

## Performance Benchmarking

### Running Benchmarks

```bash
# Go benchmarks
go test -bench=. -benchmem ./tests/benchmark/

# C++ benchmarks
cd cpp/build && make cpp-bench
./cpp-bench --benchmark_format=json > cpp_results.json

# C benchmarks
cd c/build && make c-bench
./c-bench

# Rust benchmarks
cd rust && cargo bench

# Comparative analysis
python tests/benchmark/compare_benchmarks.py
```

### Benchmark Metrics

- **Node Creation**: Time to initialize mesh node
- **Message Send**: Throughput for message broadcasting
- **Crypto Operations**: Encryption/decryption performance
- **Protocol Operations**: Flooding, gossip, consensus performance
- **Memory Usage**: Peak memory consumption
- **CPU Utilization**: Core usage patterns

### Performance Targets

| Operation | Target (ops/sec) | Go | C++ | C | Rust |
|-----------|------------------|----|----|---|------|
| Node Creation | 1000+ | ✓ | ✓ | ✓ | ✓ |
| Message Send | 10000+ | ✓ | ✓ | ✓ | ✓ |
| Encryption | 1000+ | ✓ | ✓ | ✓ | ✓ |
| Flooding | 5000+ | ✓ | ✓ | ✓ | ✓ |

## Security Testing

### Security Audit Tests

```bash
# Run security tests
go test ./tests/security/... -v

# C++ security tests
cd cpp/build && make security-test
./security-test

# Memory safety checks
valgrind --leak-check=full ./go/bin/mesh-broker
valgrind --leak-check=full ./cpp/build/mesh-broker-cpp
```

### Security Checks

- ✅ **Encryption**: AES-GCM, X25519 key exchange
- ✅ **Authentication**: Ed25519 signatures
- ✅ **Replay Protection**: Message sequencing
- ✅ **Memory Safety**: Bounds checking, no leaks
- ✅ **Timing Attacks**: Constant-time operations
- ✅ **Key Management**: Secure key storage

### Penetration Testing

```bash
# Network fuzzing
go-fuzz -bin=./go/bin/mesh-broker

# Crypto fuzzing
afl-fuzz -i test_cases -o findings ./cpp/build/mesh-crypto-fuzz
```

## Platform Compatibility

### Supported Platforms

| OS | Architecture | Go | C++ | C | Rust |
|----|--------------|----|----|---|------|
| Linux | x86_64 | ✅ | ✅ | ✅ | ✅ |
| Linux | ARM64 | ✅ | ✅ | ✅ | ✅ |
| macOS | x86_64 | ✅ | ✅ | ✅ | ✅ |
| macOS | ARM64 (M1/M2) | ✅ | ✅ | ✅ | ✅ |
| Windows | x86_64 | ✅ | ✅ | ✅ | ✅ |
| FreeBSD | x86_64 | ✅ | ⚠️ | ⚠️ | ✅ |

### Platform-Specific Tests

```bash
# Linux-specific
go test -tags linux ./tests/platform/...

# macOS-specific
go test -tags darwin ./tests/platform/...

# Windows-specific
go test -tags windows ./tests/platform/...
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Comprehensive Testing
on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        go-version: [1.21.x]

    steps:
    - uses: actions/checkout@v3

    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: ${{ matrix.go-version }}

    - name: Test Go
      run: make test-go

    - name: Test C++
      run: make test-cpp

    - name: Test C
      run: make test-c

    - name: Test Rust
      run: make test-rust

    - name: Cross-language tests
      run: make test-interop

    - name: Benchmarks
      run: make benchmark

    - name: Security audit
      run: make security-test
```

### Test Results Storage

```bash
# Store test results
go test -json ./... > test_results.json

# Upload to storage
aws s3 cp test_results.json s3://katya-mesh-test-results/

# Generate coverage reports
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

## Test Results Analysis

### Performance Analysis

```python
# analyze_benchmarks.py
import json
import matplotlib.pyplot as plt

def analyze_results():
    with open('benchmark_results.json') as f:
        results = json.load(f)

    # Generate performance charts
    for lang in ['go', 'cpp', 'c', 'rust']:
        if lang in results:
            create_performance_chart(results[lang], lang)

    # Compare across languages
    compare_languages(results)

def create_performance_chart(data, language):
    operations = list(data.keys())
    times = [data[op] for op in operations]

    plt.figure(figsize=(10, 6))
    plt.bar(operations, times)
    plt.title(f'{language.upper()} Performance Benchmarks')
    plt.ylabel('Time (ns)')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f'{language}_benchmarks.png')

if __name__ == '__main__':
    analyze_results()
```

### Test Coverage

```bash
# Go coverage
go test -cover ./...

# C++ coverage (with gcov)
cmake .. -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=ON
make
lcov --capture --directory . --output-file coverage.info
genhtml coverage.info --output-directory coverage_html

# Rust coverage
cargo install cargo-tarpaulin
cargo tarpaulin --out Html
```

### Failure Analysis

```bash
# Find flaky tests
go test -count=10 ./... 2>&1 | grep FAIL

# Race condition detection
go test -race ./...

# Memory leak detection
go test -memprofile=mem.out ./...
go tool pprof mem.out
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Use different ports for each test run
2. **Permission denied**: Run with appropriate permissions for network operations
3. **Missing dependencies**: Install all required system libraries
4. **Timeout errors**: Increase timeout values for slow operations

### Debug Mode

```bash
# Enable debug logging
export KATYA_MESH_DEBUG=1

# Run with verbose output
go test -v ./tests/interop/...

# Debug specific test
go test -run TestCrossLanguageMessageExchange -v
```

## Contributing

When adding new tests:

1. Follow existing naming conventions
2. Add appropriate test categories
3. Include both positive and negative test cases
4. Update this documentation
5. Ensure cross-platform compatibility

## Performance Regression Detection

```bash
# Baseline performance
go test -bench=. -benchmem -count=10 ./tests/benchmark/ > baseline.txt

# Compare with current
go test -bench=. -benchmem ./tests/benchmark/ > current.txt

# Check for regressions
benchstat baseline.txt current.txt
```

This comprehensive testing suite ensures that Katya Mesh maintains high quality, performance, and security across all implementations and platforms.
