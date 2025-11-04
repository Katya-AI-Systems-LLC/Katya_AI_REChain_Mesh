# Migration Guide for Katya AI REChain Mesh

This guide provides comprehensive instructions for migrating between different Git platforms, upgrading between major versions, and transitioning infrastructure components in the Katya AI REChain Mesh project.

## Table of Contents

- [Overview](#overview)
- [Git Platform Migration](#git-platform-migration)
- [Version Upgrades](#version-upgrades)
- [Infrastructure Migration](#infrastructure-migration)
- [Data Migration](#data-migration)
- [Testing Migration](#testing-migration)
- [Rollback Procedures](#rollback-procedures)
- [Troubleshooting](#troubleshooting)

## Overview

Migration scenarios covered in this guide:

- **Git Platform Migration**: Moving between GitHub, GitLab, Bitbucket, etc.
- **Major Version Upgrades**: Breaking changes between major versions
- **Infrastructure Changes**: Database, cloud provider, or architecture changes
- **Data Migration**: User data, configuration, and state migration
- **Testing Environment**: Migrating testing infrastructure

Each migration type includes:
- Pre-migration checklist
- Step-by-step procedures
- Validation steps
- Rollback procedures
- Troubleshooting guides

## Git Platform Migration

### Platform Migration Overview

Our project supports 10+ Git platforms simultaneously. Migration between platforms involves:

1. **Repository Synchronization**: Ensuring all branches and tags are present
2. **CI/CD Pipeline Migration**: Adapting workflows for new platform
3. **Issue and PR Migration**: Transferring issues, pull requests, and discussions
4. **Team Access Migration**: Updating permissions and access controls
5. **Documentation Updates**: Updating links and references

### Migration Checklist

- [ ] **Backup**: Complete backup of current platform data
- [ ] **Access**: Ensure access to both source and target platforms
- [ ] **Team Communication**: Notify team of migration timeline
- [ ] **CI/CD**: Test pipelines on target platform
- [ ] **DNS/URLs**: Update any hardcoded platform-specific URLs
- [ ] **Documentation**: Update platform-specific documentation

### GitHub to GitLab Migration

#### Step 1: Repository Setup

```bash
# Clone from GitHub
git clone https://github.com/username/katya-ai-rechain-mesh.git
cd katya-ai-rechain-mesh

# Add GitLab remote
git remote add gitlab https://gitlab.com/username/katya-ai-rechain-mesh.git

# Push all branches and tags
git push gitlab --all
git push gitlab --tags

# Set GitLab as default remote
git remote set-url origin https://gitlab.com/username/katya-ai-rechain-mesh.git
```

#### Step 2: CI/CD Pipeline Migration

```yaml
# .gitlab-ci.yml (converted from .github/workflows)
stages:
  - test
  - build
  - deploy

flutter_test:
  stage: test
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter test --coverage
  coverage: '/Coverage: (\d+\.\d+%)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura.xml

build_android:
  stage: build
  script:
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/apk/release/app-release.apk
  only:
    - main
```

#### Step 3: Issue Migration

```bash
# Export GitHub issues (using GitHub CLI)
gh issue list --json number,title,labels,assignees > github-issues.json

# Import to GitLab (using GitLab CLI or API)
# Note: Manual process for complex migrations
# Use third-party tools like:
# - github-to-gitlab
# - gitlab-migrator
```

#### Step 4: Update Documentation

```markdown
<!-- Update README.md -->
# Katya AI REChain Mesh

[![GitLab CI](https://gitlab.com/username/katya-ai-rechain-mesh/badges/main/pipeline.svg)](https://gitlab.com/username/katya-ai-rechain-mesh/-/pipelines)
[![Coverage](https://gitlab.com/username/katya-ai-rechain-mesh/badges/main/coverage.svg)](https://gitlab.com/username/katya-ai-rechain-mesh/-/graphs/main/charts)

<!-- Update contribution links -->
Contributing: [CONTRIBUTING.md](https://gitlab.com/username/katya-ai-rechain-mesh/-/blob/main/CONTRIBUTING.md)
Issues: [GitLab Issues](https://gitlab.com/username/katya-ai-rechain-mesh/-/issues)
```

### Cross-Platform Synchronization

```bash
# sync_platforms.sh
#!/bin/bash

PLATFORMS=("github" "gitlab" "bitbucket" "sourcehut" "codeberg" "gitea" "gitee" "sourcecraft" "gitflic" "gitverse")
BRANCHES=("main" "develop")
TAGS=("v*")

for platform in "${PLATFORMS[@]}"; do
    echo "🔄 Syncing with $platform"

    # Sync branches
    for branch in "${BRANCHES[@]}"; do
        git push $platform $branch
    done

    # Sync tags
    git push $platform --tags

    echo "✅ $platform synced"
done

echo "🎉 All platforms synchronized!"
```

## Version Upgrades

### Major Version Migration (2.x → 3.x)

#### Breaking Changes in v3.0.0

- **API Endpoints**: `/api/v2/*` → `/api/v3/*`
- **Configuration Format**: YAML → JSON
- **Database Schema**: New required fields
- **Dependencies**: Updated Flutter and Dart versions

#### Migration Steps

##### Step 1: Pre-Migration Assessment

```bash
# Check current version
cat VERSION
# Should show 2.x.x

# Backup current configuration
cp config/production.yaml config/production.yaml.backup

# Check for deprecated features
flutter pub outdated
flutter analyze | grep -i "deprecated"
```

##### Step 2: Update Dependencies

```yaml
# pubspec.yaml changes
dependencies:
  flutter:
    sdk: flutter
  # Updated versions
  katya_mesh_core: ^3.0.0
  katya_blockchain: ^3.0.0
  katya_ai_engine: ^3.0.0

# Remove deprecated packages
# - old_package: any
```

```bash
# Update dependencies
flutter pub upgrade

# Clean and rebuild
flutter clean
flutter pub get
```

##### Step 3: Code Migration

```dart
// Before (v2.x)
import 'package:katya_mesh/api/v2/client.dart';

class ApiService {
  final ApiClient _client = ApiClient(baseUrl: '/api/v2');

  Future<User> getUser(String id) async {
    return _client.get('/users/$id');
  }
}

// After (v3.x)
import 'package:katya_mesh/api/v3/client.dart';

class ApiService {
  final ApiClientV3 _client = ApiClientV3(baseUrl: '/api/v3');

  Future<User> getUser(String id) async {
    // New error handling
    try {
      final response = await _client.get('/users/$id');
      return User.fromJson(response.data);
    } on ApiException catch (e) {
      // New exception type
      throw UserFetchException('Failed to fetch user: ${e.message}');
    }
  }
}
```

##### Step 4: Configuration Migration

```yaml
# config/production.yaml (v2.x)
api:
  version: v2
  base_url: https://api.katya-ai-rechain-mesh.com
database:
  type: postgresql
  host: localhost

# config/production.json (v3.x)
{
  "api": {
    "version": "v3",
    "baseUrl": "https://api.katya-ai-rechain-mesh.com",
    "timeout": 30000
  },
  "database": {
    "type": "postgresql",
    "host": "localhost",
    "ssl": true
  }
}
```

##### Step 5: Database Migration

```sql
-- Migration script: 002_add_new_fields.sql
BEGIN;

-- Add new required fields
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT false;
ALTER TABLE mesh_nodes ADD COLUMN IF NOT EXISTS last_health_check TIMESTAMP;

-- Update existing records
UPDATE users SET profile_completed = true WHERE created_at < '2024-01-01';

COMMIT;
```

```bash
# Run migrations
./scripts/migrate-database.sh --version 3.0.0

# Validate migration
./scripts/validate-migration.sh
```

##### Step 6: Testing Migration

```bash
# Run migration tests
flutter test test/migration/

# Integration tests with new API
flutter test integration_test --dart-define=MIGRATION_TEST=true

# Performance regression tests
flutter test test/performance/ --benchmark
```

### Minor Version Migration (2.1.x → 2.2.x)

Minor version migrations are backward compatible but may include new features.

```bash
# Update version
echo "2.2.0" > VERSION

# Update dependencies (non-breaking)
flutter pub upgrade

# Test compatibility
flutter test --platform chrome  # Web
flutter test --platform android # Mobile
flutter test --platform linux   # Desktop
```

## Infrastructure Migration

### Database Migration

#### PostgreSQL to CockroachDB

```bash
# Export data from PostgreSQL
pg_dump -h localhost -U katya_user katya_db > katya_backup.sql

# Convert schema for CockroachDB
./scripts/convert-postgres-to-cockroach.sh katya_backup.sql > katya_cockroach.sql

# Import to CockroachDB
cockroach sql --url 'postgresql://user:password@cockroach-host:26257/katya_db?sslmode=require' < katya_cockroach.sql
```

#### Migration Validation

```sql
-- Validate data integrity
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM mesh_nodes;
SELECT COUNT(*) FROM messages;

-- Check constraints
SELECT * FROM information_schema.table_constraints WHERE table_name = 'users';

-- Performance validation
EXPLAIN ANALYZE SELECT * FROM messages WHERE created_at > NOW() - INTERVAL '1 day';
```

### Cloud Provider Migration

#### AWS to Google Cloud

##### Step 1: Infrastructure as Code Migration

```terraform
# main.tf (AWS)
resource "aws_instance" "mesh_node" {
  ami           = "ami-12345"
  instance_type = "t3.medium"
}

# main.tf (GCP)
resource "google_compute_instance" "mesh_node" {
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
}
```

##### Step 2: Service Migration

```bash
# Export AWS resources
aws ec2 describe-instances --filters "Name=tag:Project,Values=KatyaMesh" > aws_instances.json
aws rds describe-db-instances --db-instance-identifier katya-db > aws_db.json

# Import to GCP (using migration tools)
gcloud migration vms initialize
gcloud migration vms create vm-migration-1 --source=aws --target=gcp
```

##### Step 3: DNS and Load Balancer Migration

```bash
# Update DNS records
aws route53 list-resource-record-sets --hosted-zone-id Z12345 > route53_records.json

# Create GCP Cloud DNS
gcloud dns managed-zones create katya-mesh --dns-name=katya-ai-rechain-mesh.com
gcloud dns record-sets import route53_records.json --zone=katya-mesh
```

### Container Orchestration Migration

#### Docker Compose to Kubernetes

```yaml
# docker-compose.yml
version: '3.8'
services:
  api:
    image: katya-mesh/api:v2.1.0
    ports:
      - "8080:8080"

# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: katya-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: katya-api
  template:
    metadata:
      labels:
        app: katya-api
    spec:
      containers:
      - name: api
        image: katya-mesh/api:v2.1.0
        ports:
        - containerPort: 8080
```

## Data Migration

### User Data Migration

```python
# migrate_user_data.py
import psycopg2
from pymongo import MongoClient

def migrate_users():
    # Connect to old database
    old_conn = psycopg2.connect("dbname=katya_old user=katya")
    old_cur = old_conn.cursor()

    # Connect to new database
    new_client = MongoClient('mongodb://localhost:27017/')
    new_db = new_client.katya_new

    # Migrate users
    old_cur.execute("SELECT id, username, email, created_at FROM users")
    users = old_cur.fetchall()

    for user in users:
        user_doc = {
            '_id': user[0],
            'username': user[1],
            'email': user[2],
            'created_at': user[3],
            'migrated': True,
            'migration_date': datetime.utcnow()
        }
        new_db.users.insert_one(user_doc)

    print(f"✅ Migrated {len(users)} users")

if __name__ == '__main__':
    migrate_users()
```

### Configuration Migration

```bash
# migrate_config.sh
#!/bin/bash

# Convert YAML to JSON
python3 -c "
import yaml
import json
import sys

with open('config/old_config.yaml', 'r') as f:
    config = yaml.safe_load(f)

# Transform configuration structure
new_config = {
    'api': {
        'baseUrl': config['api']['base_url'],
        'version': 'v3',
        'timeout': config.get('api', {}).get('timeout', 30000)
    },
    'database': config['database'],
    'features': config.get('features', {})
}

with open('config/new_config.json', 'w') as f:
    json.dump(new_config, f, indent=2)
"

echo "✅ Configuration migrated"
```

### File Storage Migration

```bash
# migrate_files.sh
#!/bin/bash

# Migrate from local storage to cloud storage
SOURCE_DIR="/var/katya/files"
BUCKET="katya-mesh-files"

# Upload files to cloud storage
aws s3 sync $SOURCE_DIR s3://$BUCKET/ --delete

# Update database references
psql -d katya_db -c "
UPDATE files
SET url = REPLACE(url, '/files/', 'https://storage.googleapis.com/$BUCKET/')
WHERE url LIKE '/files/%';
"

echo "✅ Files migrated to cloud storage"
```

## Testing Migration

### Migration Testing Strategy

1. **Unit Tests**: Test individual migration functions
2. **Integration Tests**: Test end-to-end migration workflows
3. **Performance Tests**: Ensure migration doesn't impact performance
4. **Rollback Tests**: Test rollback procedures
5. **Data Validation**: Verify data integrity post-migration

### Migration Test Suite

```dart
// test/migration/user_migration_test.dart
import 'package:test/test.dart';
import 'package:katya_mesh/migration/user_migration.dart';

void main() {
  group('User Migration', () {
    late DatabaseHelper oldDb;
    late DatabaseHelper newDb;

    setUp(() async {
      oldDb = await DatabaseHelper.create(version: 2);
      newDb = await DatabaseHelper.create(version: 3);
    });

    tearDown(() async {
      await oldDb.close();
      await newDb.close();
    });

    test('should migrate user data correctly', () async {
      // Insert test data in old format
      await oldDb.insert('users', {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'created_at': '2023-01-01T00:00:00Z'
      });

      // Run migration
      final migrator = UserMigrator(oldDb, newDb);
      await migrator.migrate();

      // Verify migration
      final migratedUser = await newDb.query('users', where: 'id = ?', whereArgs: [1]);
      expect(migratedUser.length, equals(1));
      expect(migratedUser.first['username'], equals('testuser'));
      expect(migratedUser.first['migrated'], isTrue);
    });

    test('should handle migration errors gracefully', () async {
      // Test error scenarios
      await oldDb.insert('users', {'id': 1, 'invalid_field': 'test'});

      final migrator = UserMigrator(oldDb, newDb);
      expect(() => migrator.migrate(), throwsException);
    });
  });
}
```

### Performance Testing

```bash
# performance_migration_test.sh
#!/bin/bash

echo "🧪 Running migration performance tests"

# Measure migration time
START_TIME=$(date +%s)

# Run migration
./scripts/migrate-database.sh

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "Migration completed in ${DURATION} seconds"

# Check performance thresholds
if [ $DURATION -gt 300 ]; then
    echo "⚠️ Migration took longer than 5 minutes"
    exit 1
fi

echo "✅ Migration performance acceptable"
```

## Rollback Procedures

### Migration Rollback

```bash
# rollback_migration.sh
#!/bin/bash

MIGRATION_VERSION=$1

echo "🔄 Rolling back migration to version $MIGRATION_VERSION"

# Stop application
docker-compose down

# Restore database backup
./scripts/restore-database-backup.sh $MIGRATION_VERSION

# Restore configuration
cp config/production.json.backup config/production.json

# Restore code version
git checkout tags/v$MIGRATION_VERSION

# Restart application
docker-compose up -d

# Run health checks
./scripts/health-check.sh

echo "✅ Rollback to version $MIGRATION_VERSION completed"
```

### Platform Migration Rollback

```bash
# rollback_platform.sh
#!/bin/bash

TARGET_PLATFORM=$1

echo "🔄 Rolling back to $TARGET_PLATFORM"

# Switch back to original platform
git remote set-url origin https://$TARGET_PLATFORM.com/username/katya-ai-rechain-mesh.git

# Restore platform-specific configurations
cp .github/workflows/ci.yml.backup .github/workflows/ci.yml
cp .gitlab-ci.yml.backup .gitlab-ci.yml

# Update documentation links
./scripts/update-platform-links.sh $TARGET_PLATFORM

echo "✅ Rollback to $TARGET_PLATFORM completed"
```

## Troubleshooting

### Common Migration Issues

#### Database Connection Issues

```bash
# Test database connections
psql -h localhost -U katya_user -d katya_db -c "SELECT 1;"

# Check connection pool settings
cat config/database.json | jq '.pool'

# Monitor connection count
watch -n 1 "psql -h localhost -U katya_user -d katya_db -c 'SELECT count(*) FROM pg_stat_activity;'"
```

#### Data Corruption Issues

```sql
-- Check data integrity
SELECT
    schemaname,
    tablename,
    n_tup_ins AS inserts,
    n_tup_upd AS updates,
    n_tup_del AS deletes
FROM pg_stat_user_tables;

-- Validate foreign key constraints
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints AS tc
WHERE tc.constraint_type = 'FOREIGN KEY';
```

#### Performance Degradation

```bash
# Monitor system resources during migration
top -b -n 1 | head -20

# Check disk I/O
iostat -x 1 5

# Monitor database performance
psql -c "SELECT * FROM pg_stat_activity;"

# Check for slow queries
psql -c "SELECT query, total_time, calls FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"
```

#### Git Synchronization Issues

```bash
# Check repository status
git status
git remote -v

# Resolve conflicts
git fetch --all
git merge origin/main

# Force push if necessary (dangerous!)
# git push --force-with-lease origin main

# Verify synchronization
./scripts/verify-sync.sh
```

### Migration Monitoring

```bash
# monitor_migration.sh
#!/bin/bash

LOG_FILE="migration_$(date +%Y%m%d_%H%M%S).log"

echo "📊 Starting migration monitoring" | tee -a $LOG_FILE

# Monitor disk usage
df -h | tee -a $LOG_FILE

# Monitor memory usage
free -h | tee -a $LOG_FILE

# Monitor database connections
psql -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | tee -a $LOG_FILE

# Monitor migration progress
tail -f migration.log | tee -a $LOG_FILE

echo "✅ Migration monitoring completed" | tee -a $LOG_FILE
```

### Getting Help

If you encounter issues during migration:

1. **Check Logs**: Review migration logs for error messages
2. **Community Support**: Post in GitHub Discussions or Discord
3. **Professional Services**: Contact Katya AI support for complex migrations
4. **Documentation**: Refer to platform-specific migration guides

## Related Documentation

- [Contributing Guide](CONTRIBUTING.md)
- [Branching Strategy](BRANCHING_STRATEGY.md)
- [Release Process](RELEASE_PROCESS.md)
- [Git Systems Guide](GIT_SYSTEMS_GUIDE.md)
- [Backup and Recovery](BACKUP_RECOVERY.md)

---

This migration guide ensures smooth transitions between platforms, versions, and infrastructure components while maintaining data integrity and system reliability.
