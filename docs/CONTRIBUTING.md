# Contributing to Katya AI REChain Mesh

Welcome! We're excited that you're interested in contributing to the Katya AI REChain Mesh project. This document provides comprehensive guidelines for contributing to our decentralized AI mesh infrastructure.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)
- [Community](#community)

## Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code. Please report unacceptable behavior to [maintainers@katya-ai-rechain-mesh.com](mailto:maintainers@katya-ai-rechain-mesh.com).

## Getting Started

### Prerequisites

- **Flutter SDK**: Latest stable version (3.16.0+)
- **Dart SDK**: 3.2.0+
- **Go**: 1.21+
- **Rust**: Latest stable
- **C++**: C++17 compatible compiler
- **Git**: Latest version
- **Docker**: For containerized development

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/Katya-AI-Systems-LLC/Katya_AI_REChain_Mesh.git
cd Katya_AI_REChain_Mesh

# Set up Flutter
flutter doctor
flutter pub get

# Set up Go dependencies
cd go && go mod download

# Set up Rust dependencies
cd rust && cargo build

# Run initial tests
make test-all
```

## Development Environment Setup

### IDE Configuration

#### VS Code (Recommended)
```json
{
  "dart.flutterSdkPath": "path/to/flutter",
  "go.useLanguageServer": true,
  "rust-analyzer.checkOnSave.command": "clippy",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  }
}
```

#### IntelliJ/Android Studio
- Install Flutter and Dart plugins
- Enable Dart analysis
- Configure code style according to our standards

### Environment Variables

Create a `.env` file in the project root:

```bash
# Development environment
FLUTTER_ENV=development
API_BASE_URL=http://localhost:8080
DEBUG_MODE=true

# Git platform tokens (for CI/CD testing)
GITHUB_TOKEN=your_github_token
GITLAB_TOKEN=your_gitlab_token
BITBUCKET_TOKEN=your_bitbucket_token

# Database
DATABASE_URL=postgresql://localhost:5432/katya_mesh
REDIS_URL=redis://localhost:6379

# AI/ML
OPENAI_API_KEY=your_openai_key
GEMINI_API_KEY=your_gemini_key
```

## Development Workflow

### Branching Strategy

We follow a modified Git Flow approach:

```bash
# Feature branches
git checkout -b feature/amazing-feature

# Bug fixes
git checkout -b bugfix/issue-description

# Hotfixes (from main)
git checkout -b hotfix/critical-bug-fix

# Release branches
git checkout -b release/v1.2.0
```

See [BRANCHING_STRATEGY.md](BRANCHING_STRATEGY.md) for detailed branching guidelines.

### Commit Messages

Follow conventional commit format:

```bash
# Format: type(scope): description

# Examples
feat(mesh): add Bluetooth LE discovery
fix(ui): resolve voting display bug
docs(api): update endpoint documentation
refactor(core): optimize message routing
test(integration): add cross-platform tests
chore(deps): update Flutter dependencies
```

### Commit Signing

All commits must be signed:

```bash
# Configure Git to sign commits
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_GPG_KEY_ID

# Or use SSH signing
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519
```

## Coding Standards

### Flutter/Dart

```dart
// Good: Clear naming, proper types, documentation
class MeshNodeManager {
  final MeshRepository _repository;
  final Logger _logger;

  MeshNodeManager(this._repository, this._logger);

  /// Discovers nearby mesh nodes using multiple protocols
  Future<List<MeshNode>> discoverNodes({
    required DiscoveryConfig config,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _logger.info('Starting node discovery with config: $config');

    try {
      final nodes = await _repository.discoverNodes(config, timeout);
      _logger.info('Discovered ${nodes.length} nodes');
      return nodes;
    } catch (e) {
      _logger.error('Node discovery failed', e);
      rethrow;
    }
  }
}

// Bad: Unclear naming, no types, no documentation
class Manager {
  discover(config, timeout) {
    print('Starting...');
    return repo.discover(config, timeout);
  }
}
```

### Go Standards

```go
// Good: Proper error handling, context usage, documentation
package mesh

import (
    "context"
    "time"
    "github.com/katya-ai/mesh/internal/crypto"
)

// NodeDiscovery manages the discovery of mesh nodes
type NodeDiscovery struct {
    repo   Repository
    crypto *crypto.Service
    logger Logger
}

// DiscoverNodes discovers nearby mesh nodes with timeout
func (nd *NodeDiscovery) DiscoverNodes(
    ctx context.Context,
    config DiscoveryConfig,
    timeout time.Duration,
) ([]*Node, error) {
    ctx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()

    nodes, err := nd.repo.DiscoverNodes(ctx, config)
    if err != nil {
        nd.logger.Error("node discovery failed", "error", err)
        return nil, fmt.Errorf("discover nodes: %w", err)
    }

    nd.logger.Info("nodes discovered", "count", len(nodes))
    return nodes, nil
}
```

### Code Formatting

```bash
# Flutter/Dart
flutter format lib/
dart fix --apply

# Go
gofmt -w .
goimports -w .

# Rust
cargo fmt
cargo clippy

# C++
clang-format -i --style=Google src/**/*.cpp src/**/*.h
```

### Linting

```bash
# Flutter/Dart
flutter analyze

# Go
golangci-lint run

# Rust
cargo clippy -- -D warnings

# C++
cpplint src/**/*.cpp src/**/*.h
```

## Testing Guidelines

### Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── models/
│   ├── services/
│   └── utils/
├── integration/            # Integration tests
│   ├── api/
│   └── mesh/
├── e2e/                    # End-to-end tests
└── performance/           # Performance tests
```

### Writing Tests

```dart
// Flutter/Dart unit test
import 'package:flutter_test/flutter_test.dart';
import 'package:katya_mesh/src/models/mesh_node.dart';

void main() {
  group('MeshNode', () {
    test('should create valid node', () {
      final node = MeshNode(
        id: 'test-node-123',
        address: '192.168.1.100:8080',
        capabilities: [Capability.messaging, Capability.voting],
      );

      expect(node.id, equals('test-node-123'));
      expect(node.isValid(), isTrue);
      expect(node.capabilities, contains(Capability.messaging));
    });

    test('should reject invalid node addresses', () {
      expect(
        () => MeshNode(id: 'test', address: 'invalid-address'),
        throwsArgumentError,
      );
    });
  });
}
```

```go
// Go unit test
package mesh_test

import (
    "context"
    "testing"
    "time"

    "github.com/katya-ai/mesh/internal/mesh"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestNodeDiscovery_DiscoverNodes(t *testing.T) {
    ctx := context.Background()
    repo := &mockRepository{}
    discovery := mesh.NewNodeDiscovery(repo, nil)

    config := mesh.DiscoveryConfig{
        Timeout: 5 * time.Second,
        Protocols: []string{"ble", "wifi"},
    }

    nodes, err := discovery.DiscoverNodes(ctx, config)

    require.NoError(t, err)
    assert.NotEmpty(t, nodes)
    assert.True(t, len(nodes) > 0)
}
```

### Test Coverage

Maintain minimum coverage thresholds:

- **Unit Tests**: 80%+ coverage
- **Integration Tests**: 70%+ coverage
- **Critical Paths**: 90%+ coverage

```bash
# Check coverage
flutter test --coverage
go test -cover ./...
cargo test -- --nocapture

# Generate coverage reports
genhtml coverage/lcov.info -o coverage/html
go tool cover -html=coverage.out -o coverage.html
```

## Documentation

### Documentation Standards

- Use Markdown for all documentation
- Include code examples for APIs
- Keep documentation up to date with code changes
- Use consistent formatting and structure

### API Documentation

```dart
/// Represents a mesh node in the network
class MeshNode {
  /// Unique identifier for the node
  final String id;

  /// Network address (IP:port or Bluetooth MAC)
  final String address;

  /// Node capabilities
  final List<Capability> capabilities;

  /// Last seen timestamp
  final DateTime lastSeen;

  /// Creates a new mesh node
  ///
  /// [id] must be a valid UUID
  /// [address] must be a valid network address
  /// [capabilities] list of supported capabilities
  MeshNode({
    required this.id,
    required this.address,
    this.capabilities = const [],
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();
}
```

### Updating Documentation

```bash
# Update API docs
flutter pub run dartdoc

# Update README and docs
./scripts/update-docs.sh

# Check for broken links
markdown-link-check docs/**/*.md
```

## Submitting Changes

### Pull Request Process

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Write tests**
5. **Update documentation**
6. **Run all tests**
7. **Submit pull request**

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed
- [ ] All tests pass

## Documentation
- [ ] README updated
- [ ] API documentation updated
- [ ] Code comments added

## Checklist
- [ ] Code follows style guidelines
- [ ] Commit messages are conventional
- [ ] No new linting errors
- [ ] Tests have good coverage
- [ ] Documentation is updated
```

## Review Process

### Code Review Guidelines

See [CODE_REVIEW_GUIDELINES.md](CODE_REVIEW_GUIDELINES.md) for detailed review standards.

### Review Checklist

- [ ] Code follows project conventions
- [ ] Tests are comprehensive and passing
- [ ] Documentation is updated
- [ ] No security vulnerabilities
- [ ] Performance impact assessed
- [ ] Breaking changes documented

### Automated Checks

All PRs must pass:

- ✅ Code formatting checks
- ✅ Linting (no errors)
- ✅ Unit tests (80%+ coverage)
- ✅ Integration tests
- ✅ Security scanning
- ✅ License compliance

## Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General discussion and Q&A
- **Discord**: Real-time chat for contributors
- **Telegram**: Russian-speaking community
- **Email**: maintainers@katya-ai-rechain-mesh.com

### Getting Help

1. Check existing documentation
2. Search GitHub issues
3. Ask in GitHub Discussions
4. Contact maintainers directly

### Recognition

Contributors are recognized through:

- GitHub contributor statistics
- Release notes mentions
- Contributor spotlight in newsletters
- Exclusive Discord roles

## Additional Resources

- [Architecture Guide](ARCHITECTURE.md)
- [Testing Guide](TESTING_GUIDE.md)
- [Security Guide](SECURITY.md)
- [API Reference](API_REFERENCE.md)
- [Git Systems Guide](GIT_SYSTEMS_GUIDE.md)

Thank you for contributing to Katya AI REChain Mesh! 🚀
