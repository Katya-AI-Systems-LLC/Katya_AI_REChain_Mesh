# Git Branching Strategy for Katya AI REChain Mesh

This document outlines the Git branching strategy and workflow used in the Katya AI REChain Mesh project. Our strategy is designed to support multiple Git platforms, enable parallel development, and ensure stable releases across our distributed infrastructure.

## Table of Contents

- [Overview](#overview)
- [Branch Types](#branch-types)
- [Workflow](#workflow)
- [Branch Naming Conventions](#branch-naming-conventions)
- [Merge Strategies](#merge-strategies)
- [Release Management](#release-management)
- [Multi-Platform Synchronization](#multi-platform-synchronization)
- [Conflict Resolution](#conflict-resolution)
- [Automation](#automation)
- [Best Practices](#best-practices)

## Overview

We follow a **modified Git Flow** approach adapted for our multi-platform, distributed development environment. This strategy supports:

- **Parallel development** across multiple Git platforms
- **Stable releases** with comprehensive testing
- **Hotfix deployment** for critical issues
- **Feature isolation** for experimental work
- **Automated synchronization** between platforms

```
main (production)
├── release/v2.1.0
│   ├── hotfix/security-patch-2.1.1
│   └── hotfix/performance-fix-2.1.2
├── release/v2.0.0
└── develop (integration)
    ├── feature/ai-enhancements
    ├── feature/blockchain-integration
    ├── bugfix/mesh-discovery
    └── feature/quantum-optimization
```

## Branch Types

### Main Branch (`main`)

- **Purpose**: Production-ready code
- **Protection**: Strict protection rules
- **Merges**: Only from release branches or hotfixes
- **Testing**: Full CI/CD pipeline must pass
- **Platforms**: Synchronized across all Git platforms

```bash
# Protection rules for main
- Require pull request reviews (2+ reviewers)
- Require status checks to pass
- Require branches to be up to date
- Include administrators in restrictions
- Restrict pushes to specific users/teams
```

### Develop Branch (`develop`)

- **Purpose**: Integration branch for features
- **Protection**: Moderate protection
- **Merges**: Feature branches and bug fixes
- **Testing**: Integration tests must pass
- **Releases**: Source for release branches

### Release Branches (`release/v*.*.*`)

- **Purpose**: Release preparation and stabilization
- **Naming**: `release/v{major}.{minor}.{patch}`
- **Source**: `develop` branch
- **Merges**: Bug fixes only
- **Target**: `main` branch

### Feature Branches (`feature/*`)

- **Purpose**: New features and enhancements
- **Naming**: `feature/description-with-hyphens`
- **Source**: `develop` branch
- **Lifetime**: Short-lived (days to weeks)
- **Merges**: Back to `develop`

### Bug Fix Branches (`bugfix/*`)

- **Purpose**: Bug fixes for develop branch
- **Naming**: `bugfix/issue-description`
- **Source**: `develop` branch
- **Merges**: To `develop` and potentially cherry-picked to releases

### Hotfix Branches (`hotfix/*`)

- **Purpose**: Critical fixes for production
- **Naming**: `hotfix/critical-issue-description`
- **Source**: `main` branch
- **Merges**: To `main` and `develop`
- **Urgency**: High priority, fast-tracked

## Workflow

### Feature Development

```bash
# 1. Start from develop
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/ai-enhanced-mesh-routing

# 3. Develop and commit
git add .
git commit -m "feat(mesh): implement AI-enhanced routing algorithm

- Add quantum-inspired path finding
- Optimize for low-bandwidth networks
- Include fallback mechanisms"

# 4. Push and create PR
git push -u origin feature/ai-enhanced-mesh-routing

# 5. Create pull request to develop
# - Title: "feat: AI-enhanced mesh routing"
# - Description: Detailed explanation
# - Labels: enhancement, ai, mesh
```

### Release Process

```bash
# 1. Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v2.1.0

# 2. Update version numbers
echo "2.1.0" > VERSION
git add VERSION
git commit -m "chore: bump version to 2.1.0"

# 3. Final testing and stabilization
# - Run full test suite
# - Update changelog
# - Tag release

# 4. Merge to main
git checkout main
git merge release/v2.1.0 --no-ff
git tag -a v2.1.0 -m "Release v2.1.0"
git push origin main --tags

# 5. Merge back to develop
git checkout develop
git merge release/v2.1.0 --no-ff
git push origin develop

# 6. Clean up release branch
git branch -d release/v2.1.0
```

### Hotfix Process

```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-patch

# 2. Fix the issue
# - Implement fix
# - Add tests
# - Update documentation

# 3. Commit and test
git add .
git commit -m "fix(security): patch critical vulnerability CVE-2024-XXXX

- Validate all input parameters
- Add rate limiting
- Update security headers"

# 4. Merge to main
git checkout main
git merge hotfix/critical-security-patch --no-ff
git tag -a v2.0.1 -m "Hotfix v2.0.1"
git push origin main --tags

# 5. Merge to develop
git checkout develop
git merge hotfix/critical-security-patch --no-ff
git push origin develop

# 6. Clean up
git branch -d hotfix/critical-security-patch
```

## Branch Naming Conventions

### General Rules

- Use lowercase letters
- Use hyphens (-) to separate words
- Be descriptive but concise
- Include issue/ticket numbers when applicable

### Specific Patterns

```bash
# Features
feature/ai-enhanced-routing
feature/blockchain-bridge-integration
feature/quantum-computation-core

# Bug fixes
bugfix/mesh-discovery-crash
bugfix/voting-consensus-failure
bugfix/GH-123-memory-leak

# Hotfixes
hotfix/security-vulnerability-patch
hotfix/critical-performance-regression
hotfix/GL-456-data-corruption

# Releases
release/v2.1.0
release/v2.0.5
release/v3.0.0-beta.1

# Documentation
docs/api-reference-update
docs/contribution-guidelines
docs/migration-guide-v3
```

## Merge Strategies

### Merge Commit Strategy

```bash
# For feature branches to develop
git checkout develop
git merge feature/amazing-feature --no-ff -m "feat: amazing new feature

- Implements XYZ functionality
- Closes #123
- Tested on all platforms"

# This preserves branch history
```

### Squash Strategy

```bash
# For small, focused changes
git checkout develop
git merge feature/small-fix --squash
git commit -m "fix: small fix description"
```

### Rebase Strategy

```bash
# For keeping clean history
git checkout feature/my-feature
git rebase develop

# Interactive rebase for cleaning commits
git rebase -i develop
```

## Release Management

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

Examples:
- 2.1.0 (stable release)
- 2.1.1 (patch release)
- 3.0.0-beta.1 (pre-release)
- 2.0.5+20240101 (build metadata)
```

### Release Checklist

- [ ] All tests pass (unit, integration, e2e)
- [ ] Code coverage meets minimum requirements
- [ ] Security audit completed
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version numbers updated in all files
- [ ] Release notes prepared
- [ ] Multi-platform synchronization tested
- [ ] Rollback plan documented

### Automated Releases

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*.*.*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Run tests
        run: flutter test --coverage

      - name: Build all platforms
        run: |
          flutter build web --release
          flutter build apk --release
          flutter build ios --release --no-codesign

      - name: Create release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
```

## Multi-Platform Synchronization

### Mirror Management

Our project is mirrored across multiple Git platforms. Synchronization is handled through:

```bash
# push_mirrors.sh
#!/bin/bash

# Push to all mirrors
git push github main
git push gitlab main
git push bitbucket main
git push sourcehut main
git push codeberg main
git push gitea main
git push gitee main
git push sourcecraft main
git push gitflic main
git push gitverse main

echo "✅ Pushed to all Git platforms"
```

### Conflict Resolution Across Platforms

1. **Identify conflicts**: Check for divergent commits
2. **Resolve locally**: Merge conflicts in primary repository
3. **Push resolution**: Update all mirrors
4. **Verify sync**: Ensure all platforms have identical history

```bash
# Check for differences
git log --oneline github/main..gitlab/main
git log --oneline gitlab/main..github/main

# Resolve conflicts
git checkout main
git merge gitlab/main
# Resolve conflicts manually
git add .
git commit -m "chore: resolve merge conflicts from platform sync"
```

## Conflict Resolution

### Merge Conflict Resolution

```bash
# When conflicts occur
git status

# Edit conflicted files
# Look for >>>>>>>, ======, <<<<<<< markers

# After resolving
git add <resolved-files>
git commit -m "chore: resolve merge conflicts"

# Or abort if needed
git merge --abort
```

### Prevention Strategies

- **Small, focused commits**: Easier to resolve
- **Regular synchronization**: Daily pulls from develop
- **Clear ownership**: Assign code reviewers for areas
- **Automated testing**: Catch issues before conflicts

## Automation

### Git Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Run linting
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Linting failed. Fix issues before committing."
  exit 1
fi

# Run tests
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Fix issues before committing."
  exit 1
fi

echo "✅ Pre-commit checks passed"
```

### CI/CD Automation

```yaml
# .github/workflows/pr-checks.yml
name: PR Checks
on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze --fatal-infos --fatal-warnings

      - name: Test
        run: flutter test --coverage

      - name: Check formatting
        run: flutter format --set-exit-if-changed .
```

## Best Practices

### General Guidelines

1. **Keep branches short-lived**: Merge features within 1-2 weeks
2. **Regular commits**: Commit early and often
3. **Descriptive messages**: Write clear, conventional commit messages
4. **Code reviews**: All changes require review
5. **Testing**: Never merge untested code
6. **Documentation**: Update docs with code changes

### Branch Management

```bash
# Clean up merged branches
git branch --merged develop | grep -v develop | xargs git branch -d

# List stale branches
git branch --sort=-committerdate | head -10

# Rename branch
git branch -m old-name new-name
git push origin :old-name new-name
git push origin -u new-name
```

### Collaboration Tips

- **Communicate**: Discuss major changes before implementation
- **Pair programming**: For complex features
- **Daily standups**: Keep team aligned
- **Issue tracking**: Link commits to issues
- **Release planning**: Plan releases in advance

### Performance Considerations

- **Shallow clones**: For CI/CD pipelines
- **Partial clones**: For large repositories
- **Git LFS**: For large binary files
- **Archive cleanup**: Regular maintenance

```bash
# Optimize repository
git gc --aggressive --prune=now
git repack -a -d --depth=250 --window=250
```

## Troubleshooting

### Common Issues

1. **Divergent branches**: Regular merging prevents conflicts
2. **Lost commits**: Use `git reflog` to recover
3. **Merge conflicts**: Resolve immediately, don't delay
4. **Platform sync issues**: Check mirror configurations

### Recovery Commands

```bash
# Recover lost commits
git reflog
git checkout <commit-hash>

# Undo last commit (soft)
git reset --soft HEAD~1

# Undo last commit (hard) - DANGER
git reset --hard HEAD~1

# Recover deleted branch
git checkout -b recovered-branch <commit-hash>
```

## Related Documentation

- [Contributing Guide](CONTRIBUTING.md)
- [Code Review Guidelines](CODE_REVIEW_GUIDELINES.md)
- [Release Process](RELEASE_PROCESS.md)
- [Git Systems Guide](GIT_SYSTEMS_GUIDE.md)
- [Migration Guide](MIGRATION_GUIDE.md)

---

This branching strategy ensures our multi-platform development remains organized, efficient, and scalable. Regular reviews and updates to this document help maintain best practices across our distributed team.
