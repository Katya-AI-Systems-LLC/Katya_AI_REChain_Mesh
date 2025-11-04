# Backup and Recovery Guide for Katya AI REChain Mesh

This comprehensive guide covers backup strategies, disaster recovery procedures, and business continuity planning for the Katya AI REChain Mesh project across all platforms and components.

## Table of Contents

- [Overview](#overview)
- [Backup Strategy](#backup-strategy)
- [Data Classification](#data-classification)
- [Backup Types](#backup-types)
- [Backup Procedures](#backup-procedures)
- [Recovery Procedures](#recovery-procedures)
- [Disaster Recovery](#disaster-recovery)
- [Testing and Validation](#testing-and-validation)
- [Automation](#automation)
- [Compliance](#compliance)
- [Monitoring](#monitoring)

## Overview

Effective backup and recovery is critical for ensuring data integrity, business continuity, and regulatory compliance in our decentralized AI mesh infrastructure. Our strategy covers:

- **Multi-layered backups**: Application data, configuration, and infrastructure
- **Cross-platform synchronization**: Consistent backups across Git platforms
- **Automated processes**: Scheduled backups with minimal manual intervention
- **Comprehensive testing**: Regular recovery testing and validation
- **Compliance alignment**: Meeting regulatory requirements for data retention

## Backup Strategy

### Backup Objectives

- **RTO (Recovery Time Objective)**: Maximum 4 hours for critical systems, 24 hours for non-critical
- **RPO (Recovery Point Objective)**: Maximum 15 minutes data loss for critical data, 1 hour for non-critical
- **Retention**: 30 days for daily backups, 1 year for monthly backups, 7 years for annual backups
- **Encryption**: All backups encrypted at rest and in transit
- **Immutability**: Critical backups protected against accidental deletion

### Backup Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Database      │    │   Filesystem    │
│     Data        │    │   Backups       │    │   Backups       │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                     │                     │
          └─────────────────────┼─────────────────────┘
                                │
                    ┌─────────────────┐
                    │   Storage       │
                    │   Layer         │
                    └─────────┬───────┘
                              │
                    ┌─────────────────┐
                    │   Offsite       │
                    │   Storage       │
                    └─────────────────┘
```

### Storage Tiers

1. **Hot Storage**: Frequently accessed backups (< 24 hours old)
2. **Warm Storage**: Recent backups (1-30 days old)
3. **Cold Storage**: Long-term archival (> 30 days old)
4. **Offline Storage**: Air-gapped backups for critical data

## Data Classification

### Data Classification Levels

| Level | Description | Backup Frequency | Retention | Encryption |
|-------|-------------|------------------|-----------|------------|
| **Critical** | Core mesh data, user credentials, AI models | Continuous/15min | 7 years | AES-256 |
| **Important** | Configuration, logs, analytics | Hourly | 1 year | AES-256 |
| **Operational** | Temporary files, caches | Daily | 30 days | AES-128 |
| **Transient** | Session data, temporary uploads | As needed | 7 days | None |

### Data Inventory

```sql
-- data_inventory.sql
CREATE TABLE data_inventory (
    id SERIAL PRIMARY KEY,
    data_type VARCHAR(50) NOT NULL,
    classification VARCHAR(20) NOT NULL,
    location VARCHAR(200),
    owner_team VARCHAR(50),
    backup_schedule VARCHAR(100),
    retention_period INTERVAL,
    encryption_required BOOLEAN DEFAULT true,
    last_backup TIMESTAMP,
    backup_status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample data
INSERT INTO data_inventory (data_type, classification, location, owner_team, backup_schedule, retention_period, encryption_required) VALUES
('User Database', 'Critical', '/var/lib/postgresql', 'Backend', 'Every 15 minutes', '7 years', true),
('AI Models', 'Critical', '/opt/katya/models', 'AI', 'Daily', '7 years', true),
('Configuration', 'Important', '/etc/katya', 'DevOps', 'Hourly', '1 year', true),
('Application Logs', 'Important', '/var/log/katya', 'DevOps', 'Daily', '90 days', true),
('User Uploads', 'Operational', '/var/www/uploads', 'Frontend', 'Daily', '30 days', true);
```

## Backup Types

### Full Backups

Complete system backups containing all data and configurations.

```bash
# Full system backup script
#!/bin/bash
# full_backup.sh

BACKUP_DIR="/backups/full"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="katya_mesh_full_$TIMESTAMP"

echo "Starting full backup: $BACKUP_NAME"

# Create backup directory
mkdir -p $BACKUP_DIR/$BACKUP_NAME

# Backup database
pg_dump -h localhost -U katya_user -d katya_db > $BACKUP_DIR/$BACKUP_NAME/database.sql

# Backup application data
tar -czf $BACKUP_DIR/$BACKUP_NAME/app_data.tar.gz /opt/katya/data/

# Backup configuration
tar -czf $BACKUP_DIR/$BACKUP_NAME/config.tar.gz /etc/katya/

# Backup AI models
tar -czf $BACKUP_DIR/$BACKUP_NAME/models.tar.gz /opt/katya/models/

# Encrypt backup
openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/$BACKUP_NAME -out $BACKUP_DIR/$BACKUP_NAME.enc -k $ENCRYPTION_KEY

# Upload to cloud storage
aws s3 cp $BACKUP_DIR/$BACKUP_NAME.enc s3://katya-backups/full/

# Cleanup local copy
rm -rf $BACKUP_DIR/$BACKUP_NAME*

echo "Full backup completed: $BACKUP_NAME"
```

### Incremental Backups

Backups containing only changes since the last backup.

```bash
# Incremental backup script
#!/bin/bash
# incremental_backup.sh

LAST_BACKUP=$(ls /backups/incremental/ | tail -1)
BACKUP_DIR="/backups/incremental"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="katya_mesh_inc_$TIMESTAMP"

echo "Starting incremental backup: $BACKUP_NAME"

# Create backup directory
mkdir -p $BACKUP_DIR/$BACKUP_NAME

# Use rsync for incremental backup
rsync -av --link-dest=$BACKUP_DIR/$LAST_BACKUP /opt/katya/data/ $BACKUP_DIR/$BACKUP_NAME/

# Encrypt and upload
tar -czf - $BACKUP_DIR/$BACKUP_NAME | openssl enc -aes-256-cbc -salt -out $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc -k $ENCRYPTION_KEY

aws s3 cp $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc s3://katya-backups/incremental/

# Update last backup reference
echo $BACKUP_NAME > /backups/last_incremental

echo "Incremental backup completed: $BACKUP_NAME"
```

### Differential Backups

Backups containing all changes since the last full backup.

```bash
# Differential backup script
#!/bin/bash
# differential_backup.sh

LAST_FULL=$(cat /backups/last_full)
BACKUP_DIR="/backups/differential"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="katya_mesh_diff_$TIMESTAMP"

echo "Starting differential backup: $BACKUP_NAME"

# Create backup directory
mkdir -p $BACKUP_DIR/$BACKUP_NAME

# Backup changes since last full backup
rsync -av --compare-dest=$LAST_FULL /opt/katya/data/ $BACKUP_DIR/$BACKUP_NAME/

# Encrypt and upload
tar -czf $BACKUP_DIR/$BACKUP_NAME.tar.gz $BACKUP_DIR/$BACKUP_NAME/
openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/$BACKUP_NAME.tar.gz -out $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc -k $ENCRYPTION_KEY

aws s3 cp $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc s3://katya-backups/differential/

echo "Differential backup completed: $BACKUP_NAME"
```

### Snapshot Backups

Point-in-time filesystem snapshots.

```bash
# ZFS snapshot backup
#!/bin/bash
# zfs_snapshot.sh

SNAPSHOT_NAME="katya_mesh_$(date +%Y%m%d_%H%M%S)"

echo "Creating ZFS snapshot: $SNAPSHOT_NAME"

# Create snapshot
zfs snapshot tank/katya@$SNAPSHOT_NAME

# Send to backup pool
zfs send tank/katya@$SNAPSHOT_NAME | zfs receive backup/katya@$SNAPSHOT_NAME

# Clean old snapshots (keep last 30)
zfs list -t snapshot -o name tank/katya | head -n -30 | xargs -I {} zfs destroy {}

echo "ZFS snapshot created: $SNAPSHOT_NAME"
```

## Backup Procedures

### Database Backups

#### PostgreSQL Backup

```bash
# PostgreSQL backup with compression and encryption
#!/bin/bash
# postgres_backup.sh

DB_HOST="localhost"
DB_USER="katya_backup"
DB_NAME="katya_db"
BACKUP_DIR="/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/katya_db_$TIMESTAMP.sql.gz.enc"

echo "Starting PostgreSQL backup"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup with compression
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME | gzip | openssl enc -aes-256-cbc -salt -out $BACKUP_FILE -k $ENCRYPTION_KEY

# Verify backup integrity
echo "Verifying backup integrity..."
openssl enc -d -aes-256-cbc -in $BACKUP_FILE -k $ENCRYPTION_KEY | gunzip | pg_restore --list > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Backup integrity verified"
else
    echo "❌ Backup integrity check failed"
    exit 1
fi

# Upload to cloud
aws s3 cp $BACKUP_FILE s3://katya-backups/postgres/

# Clean old backups (keep last 30)
cd $BACKUP_DIR
ls -t *.enc | tail -n +31 | xargs rm -f

echo "PostgreSQL backup completed: $BACKUP_FILE"
```

#### MongoDB Backup

```bash
# MongoDB backup for AI model metadata
#!/bin/bash
# mongodb_backup.sh

BACKUP_DIR="/backups/mongodb"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="katya_ai_$TIMESTAMP"

echo "Starting MongoDB backup"

# Create backup
mongodump --db katya_ai --out $BACKUP_DIR/$BACKUP_NAME

# Compress and encrypt
tar -czf $BACKUP_DIR/$BACKUP_NAME.tar.gz $BACKUP_DIR/$BACKUP_NAME/
openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/$BACKUP_NAME.tar.gz -out $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc -k $ENCRYPTION_KEY

# Upload to cloud
aws s3 cp $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc s3://katya-backups/mongodb/

# Cleanup
rm -rf $BACKUP_DIR/$BACKUP_NAME*

echo "MongoDB backup completed: $BACKUP_NAME"
```

### Application Backups

#### Configuration Backup

```bash
# Configuration backup
#!/bin/bash
# config_backup.sh

CONFIG_DIRS=("/etc/katya" "/opt/katya/config" "/home/katya/.katya")
BACKUP_DIR="/backups/config"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="katya_config_$TIMESTAMP"

echo "Starting configuration backup"

# Create backup directory
mkdir -p $BACKUP_DIR/$BACKUP_NAME

# Backup configurations
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        cp -r $dir $BACKUP_DIR/$BACKUP_NAME/
    fi
done

# Backup environment variables
env | grep -E "(KATYA|DATABASE|REDIS)" > $BACKUP_DIR/$BACKUP_NAME/environment.env

# Compress and encrypt
tar -czf $BACKUP_DIR/$BACKUP_NAME.tar.gz $BACKUP_DIR/$BACKUP_NAME/
openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/$BACKUP_NAME.tar.gz -out $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc -k $ENCRYPTION_KEY

# Upload
aws s3 cp $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc s3://katya-backups/config/

echo "Configuration backup completed: $BACKUP_NAME"
```

#### AI Model Backups

```bash
# AI model backup with versioning
#!/bin/bash
# ai_model_backup.sh

MODEL_DIR="/opt/katya/models"
BACKUP_DIR="/backups/models"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="katya_models_$TIMESTAMP"

echo "Starting AI model backup"

# Create backup with hard links for efficiency
rsync -a --link-dest=$BACKUP_DIR/$(ls $BACKUP_DIR | tail -1) $MODEL_DIR/ $BACKUP_DIR/$BACKUP_NAME/

# Create model inventory
find $BACKUP_DIR/$BACKUP_NAME -name "*.model" -o -name "*.weights" | while read model; do
    sha256sum "$model" >> $BACKUP_DIR/$BACKUP_NAME/inventory.sha256
done

# Compress and encrypt
tar -czf $BACKUP_DIR/$BACKUP_NAME.tar.gz $BACKUP_DIR/$BACKUP_NAME/
openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/$BACKUP_NAME.tar.gz -out $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc -k $ENCRYPTION_KEY

# Upload to cloud with versioning
aws s3 cp $BACKUP_DIR/$BACKUP_NAME.tar.gz.enc s3://katya-backups/models/$BACKUP_NAME.tar.gz.enc --storage-class STANDARD_IA

echo "AI model backup completed: $BACKUP_NAME"
```

### Git Repository Backups

```bash
# Git repository backup
#!/bin/bash
# git_backup.sh

REPOS=("github" "gitlab" "bitbucket" "sourcehut" "codeberg" "gitea" "gitee" "sourcecraft" "gitflic" "gitverse")
BACKUP_DIR="/backups/git"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Starting Git repository backup"

for repo in "${REPOS[@]}"; do
    echo "Backing up $repo repository"

    # Clone or update mirror
    if [ -d "$BACKUP_DIR/$repo" ]; then
        cd $BACKUP_DIR/$repo
        git fetch --all
        git fetch --tags
    else
        git clone --mirror https://$repo.com/katya-ai/katya-ai-rechain-mesh.git $BACKUP_DIR/$repo
    fi

    # Create bundle for offline backup
    git bundle create $BACKUP_DIR/${repo}_$TIMESTAMP.bundle --all

    # Encrypt bundle
    openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/${repo}_$TIMESTAMP.bundle -out $BACKUP_DIR/${repo}_$TIMESTAMP.bundle.enc -k $ENCRYPTION_KEY

    # Upload to cloud
    aws s3 cp $BACKUP_DIR/${repo}_$TIMESTAMP.bundle.enc s3://katya-backups/git/
done

echo "Git repository backup completed"
```

## Recovery Procedures

### Database Recovery

#### PostgreSQL Recovery

```bash
# PostgreSQL recovery script
#!/bin/bash
# postgres_recovery.sh

BACKUP_FILE=$1
DB_HOST="localhost"
DB_USER="katya_user"
DB_NAME="katya_db"

echo "Starting PostgreSQL recovery from $BACKUP_FILE"

# Decrypt backup
openssl enc -d -aes-256-cbc -in $BACKUP_FILE -out /tmp/recovery.sql.gz -k $ENCRYPTION_KEY

# Decompress
gunzip /tmp/recovery.sql.gz

# Stop application to prevent data corruption
systemctl stop katya-api
systemctl stop katya-mesh

# Drop and recreate database
psql -h $DB_HOST -U $DB_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -h $DB_HOST -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

# Restore from backup
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < /tmp/recovery.sql

# Restart application
systemctl start katya-api
systemctl start katya-mesh

# Verify recovery
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) FROM users;"

echo "PostgreSQL recovery completed"
```

#### Point-in-Time Recovery

```bash
# Point-in-time recovery
#!/bin/bash
# pitr_recovery.sh

RECOVERY_TIME=$1  # Format: "2024-01-15 14:30:00"
BACKUP_FILE=$2

echo "Starting point-in-time recovery to $RECOVERY_TIME"

# Restore base backup
./postgres_recovery.sh $BACKUP_FILE

# Apply WAL logs up to recovery time
cat > /tmp/recovery.conf << EOF
restore_command = 'cp /var/lib/postgresql/wal/%f %p'
recovery_target_time = '$RECOVERY_TIME'
recovery_target_action = 'promote'
EOF

# Start PostgreSQL in recovery mode
systemctl start postgresql

# Monitor recovery progress
tail -f /var/log/postgresql/postgresql.log

echo "Point-in-time recovery completed"
```

### Application Recovery

#### Full Application Recovery

```bash
# Full application recovery
#!/bin/bash
# app_recovery.sh

BACKUP_FILE=$1

echo "Starting full application recovery"

# Stop services
systemctl stop katya-api
systemctl stop katya-mesh
systemctl stop katya-ai

# Decrypt and extract backup
openssl enc -d -aes-256-cbc -in $BACKUP_FILE -k $ENCRYPTION_KEY | tar -xzf - -C /

# Restore permissions
chown -R katya:katya /opt/katya
chown -R katya:katya /etc/katya

# Restore database
./postgres_recovery.sh /backups/postgres/latest.enc

# Start services
systemctl start katya-ai
systemctl start katya-mesh
systemctl start katya-api

# Verify application health
curl -f https://api.katya-ai-rechain-mesh.com/health

echo "Full application recovery completed"
```

### File System Recovery

#### ZFS Snapshot Recovery

```bash
# ZFS snapshot recovery
#!/bin/bash
# zfs_recovery.sh

SNAPSHOT_NAME=$1
TARGET_DATASET="tank/katya"

echo "Starting ZFS snapshot recovery: $SNAPSHOT_NAME"

# Stop services
systemctl stop katya-*

# Rollback to snapshot
zfs rollback -r $TARGET_DATASET@$SNAPSHOT_NAME

# Start services
systemctl start katya-*

# Verify data integrity
./verify_data_integrity.sh

echo "ZFS snapshot recovery completed"
```

## Disaster Recovery

### Disaster Recovery Plan

#### Activation Criteria

- **Complete data center failure**
- **Cybersecurity incident with data compromise**
- **Extended service outage (>4 hours)**
- **Natural disaster affecting primary site**

#### Recovery Time Objectives

| Component | RTO | RPO | Recovery Method |
|-----------|-----|-----|-----------------|
| User Database | 2 hours | 15 minutes | Database failover |
| AI Models | 4 hours | 1 hour | Model cache restoration |
| Application Servers | 1 hour | 5 minutes | Auto-scaling activation |
| Git Repositories | 6 hours | 1 hour | Mirror synchronization |

### Disaster Recovery Procedures

#### Data Center Failover

```bash
# Data center failover script
#!/bin/bash
# failover.sh

PRIMARY_DC="us-east-1"
SECONDARY_DC="us-west-2"

echo "Initiating failover from $PRIMARY_DC to $SECONDARY_DC"

# Update DNS to point to secondary DC
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://dns-failover.json

# Start services in secondary DC
aws ecs update-service --cluster katya-cluster-$SECONDARY_DC --service katya-api --desired-count 3
aws ecs update-service --cluster katya-cluster-$SECONDARY_DC --service katya-mesh --desired-count 5

# Promote read replica to primary
aws rds failover-db-cluster --db-cluster-identifier katya-db-cluster --target-db-instance-identifier katya-db-$SECONDARY_DC

# Update application configuration
aws ssm put-parameter --name "/katya/active-dc" --value $SECONDARY_DC --overwrite

# Verify failover
curl -f https://api.katya-ai-rechain-mesh.com/health

echo "Failover to $SECONDARY_DC completed"
```

#### Cyber Incident Response

```bash
# Cyber incident recovery
#!/bin/bash
# cyber_recovery.sh

echo "Starting cyber incident recovery"

# Isolate affected systems
aws ec2 stop-instances --instance-ids $COMPROMISED_INSTANCES

# Restore from clean backup
./app_recovery.sh /backups/clean/latest.enc

# Rotate all credentials
./rotate_credentials.sh

# Update security groups
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP --protocol tcp --port 22 --cidr 0.0.0.0/0 --revoke

# Rebuild compromised systems
./rebuild_instances.sh

# Security audit
./security_audit.sh

echo "Cyber incident recovery completed"
```

## Testing and Validation

### Backup Testing

#### Backup Integrity Testing

```bash
# Backup integrity test
#!/bin/bash
# test_backup_integrity.sh

BACKUP_FILE=$1

echo "Testing backup integrity: $BACKUP_FILE"

# Test decryption
openssl enc -d -aes-256-cbc -in $BACKUP_FILE -k $ENCRYPTION_KEY -out /tmp/test_backup.tar.gz
if [ $? -ne 0 ]; then
    echo "❌ Decryption failed"
    exit 1
fi

# Test decompression
tar -tzf /tmp/test_backup.tar.gz > /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Decompression failed"
    exit 1
fi

# Test file integrity (if checksums available)
if [ -f /tmp/test_backup/inventory.sha256 ]; then
    cd /tmp/test_backup
    sha256sum -c inventory.sha256 > /dev/null
    if [ $? -ne 0 ]; then
        echo "❌ File integrity check failed"
        exit 1
    fi
fi

echo "✅ Backup integrity verified"
```

### Recovery Testing

#### Recovery Drill

```bash
# Recovery drill script
#!/bin/bash
# recovery_drill.sh

echo "Starting recovery drill"

# Create test environment
./create_test_environment.sh

# Simulate data loss
psql -c "DROP TABLE users_test;"

# Execute recovery
./postgres_recovery.sh /backups/test/latest.enc

# Verify recovery
psql -c "SELECT COUNT(*) FROM users_test;"

# Measure recovery time
END_TIME=$(date +%s)
RECOVERY_TIME=$((END_TIME - START_TIME))

if [ $RECOVERY_TIME -le 3600 ]; then  # 1 hour
    echo "✅ Recovery drill passed (RTO: ${RECOVERY_TIME}s)"
else
    echo "❌ Recovery drill failed (RTO exceeded: ${RECOVERY_TIME}s)"
fi

# Cleanup test environment
./cleanup_test_environment.sh
```

### Automated Testing

```yaml
# .github/workflows/backup-test.yml
name: Backup and Recovery Testing
on:
  schedule:
    - cron: '0 2 * * 0'  # Weekly on Sunday
  workflow_dispatch:

jobs:
  backup-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup test environment
        run: ./scripts/setup-test-env.sh

      - name: Run backup integrity tests
        run: ./scripts/test-backup-integrity.sh

      - name: Run recovery drill
        run: ./scripts/recovery-drill.sh

      - name: Generate test report
        run: ./scripts/generate-test-report.sh

      - name: Upload test results
        uses: actions/upload-artifact@v3
        with:
          name: backup-test-results
          path: test-results/
```

## Automation

### Backup Automation

```yaml
# docker-compose.backup.yml
version: '3.8'
services:
  backup-scheduler:
    image: python:3.9-slim
    volumes:
      - ./backup:/app
      - /backups:/backups
    environment:
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    command: python /app/backup_scheduler.py

  backup-monitor:
    image: prom/prometheus:v2.44.0
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/backup_monitoring.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
```

### Backup Scheduler

```python
# backup_scheduler.py
import schedule
import time
import subprocess
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_backup(backup_type):
    """Run a specific type of backup"""
    try:
        if backup_type == 'full':
            subprocess.run(['./full_backup.sh'], check=True)
        elif backup_type == 'incremental':
            subprocess.run(['./incremental_backup.sh'], check=True)
        elif backup_type == 'database':
            subprocess.run(['./postgres_backup.sh'], check=True)

        logger.info(f"{backup_type} backup completed successfully")
    except subprocess.CalledProcessError as e:
        logger.error(f"{backup_type} backup failed: {e}")

# Schedule backups
schedule.every().day.at("02:00").do(run_backup, 'full')
schedule.every(15).minutes.do(run_backup, 'incremental')
schedule.every().hour.do(run_backup, 'database')

if __name__ == '__main__':
    logger.info("Backup scheduler started")
    while True:
        schedule.run_pending()
        time.sleep(60)
```

## Compliance

### Regulatory Requirements

#### GDPR Compliance

```sql
-- GDPR data retention and deletion
CREATE OR REPLACE FUNCTION gdpr_data_cleanup()
RETURNS void AS $$
BEGIN
    -- Delete user data older than retention period
    DELETE FROM user_data
    WHERE created_at < NOW() - INTERVAL '7 years'
    AND consent_withdrawn = true;

    -- Anonymize old logs
    UPDATE audit_logs
    SET user_id = 'anonymized',
        ip_address = '0.0.0.0'
    WHERE created_at < NOW() - INTERVAL '2 years';

    -- Log cleanup action
    INSERT INTO compliance_log (action, details, performed_at)
    VALUES ('gdpr_cleanup', 'Automated GDPR data cleanup', NOW());
END;
$$ LANGUAGE plpgsql;

-- Schedule GDPR cleanup
SELECT cron.schedule('gdpr-cleanup', '0 3 * * *', 'SELECT gdpr_data_cleanup();');
```

#### HIPAA Compliance (if applicable)

```bash
# HIPAA-compliant backup encryption
#!/bin/bash
# hipaa_backup.sh

# Use FIPS-compliant encryption
openssl enc -aes-256-cbc -salt -in $DATA_FILE -out $ENCRYPTED_FILE -k $FIPS_KEY -md sha256

# Generate audit trail
echo "$(date): HIPAA backup created - $ENCRYPTED_FILE" >> /var/log/hipaa_audit.log

# Store in HIPAA-compliant storage
aws s3 cp $ENCRYPTED_FILE s3://hipaa-backups/ --sse AES256
```

### Audit Trails

```sql
-- Backup audit trail
CREATE TABLE backup_audit (
    id SERIAL PRIMARY KEY,
    backup_type VARCHAR(50) NOT NULL,
    backup_file VARCHAR(200),
    status VARCHAR(20),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    size_bytes BIGINT,
    checksum VARCHAR(64),
    performed_by VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert audit record
CREATE OR REPLACE FUNCTION log_backup(
    p_type VARCHAR(50),
    p_file VARCHAR(200),
    p_status VARCHAR(20),
    p_size BIGINT,
    p_checksum VARCHAR(64),
    p_performed_by VARCHAR(100),
    p_notes TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    INSERT INTO backup_audit (
        backup_type, backup_file, status, size_bytes,
        checksum, performed_by, notes, start_time
    ) VALUES (
        p_type, p_file, p_status, p_size,
        p_checksum, p_performed_by, p_notes, NOW()
    );
END;
$$ LANGUAGE plpgsql;
```

## Monitoring

### Backup Monitoring

```yaml
# backup_monitoring.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'backup-status'
    static_configs:
      - targets: ['localhost:9091']
    metrics_path: '/metrics'

  - job_name: 'backup-health'
    static_configs:
      - targets: ['localhost:9092']
    metrics_path: '/health'
```

### Backup Metrics

```go
// internal/monitoring/backup_metrics.go
package monitoring

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
)

var (
    BackupDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "backup_duration_seconds",
            Help: "Time taken to complete backups",
        },
        []string{"backup_type", "status"},
    )

    BackupSizeBytes = promauto.NewGaugeVec(
        prometheus.GaugeOpts{
            Name: "backup_size_bytes",
            Help: "Size of backup files",
        },
        []string{"backup_type"},
    )

    BackupSuccessTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "backup_success_total",
            Help: "Total number of successful backups",
        },
        []string{"backup_type"},
    )

    BackupFailureTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "backup_failure_total",
            Help: "Total number of failed backups",
        },
        []string{"backup_type"},
    )

    LastBackupTime = promauto.NewGaugeVec(
        prometheus.GaugeOpts{
            Name: "last_backup_timestamp",
            Help: "Timestamp of last successful backup",
        },
        []string{"backup_type"},
    )
)
```

### Alert Rules

```yaml
# backup_alerts.yml
groups:
  - name: backup-alerts
    rules:
      - alert: BackupFailed
        expr: increase(backup_failure_total[1h]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Backup failed"
          description: "Backup of type {{ $labels.backup_type }} failed"

      - alert: BackupOverdue
        expr: (time() - last_backup_timestamp) / 3600 > 25
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Backup overdue"
          description: "Backup of type {{ $labels.backup_type }} is overdue"

      - alert: BackupSizeAnomaly
        expr: abs(backup_size_bytes - backup_size_bytes offset 24h) / backup_size_bytes > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Backup size anomaly"
          description: "Backup size for {{ $labels.backup_type }} changed significantly"
```

---

This backup and recovery guide ensures the Katya AI REChain Mesh maintains data integrity, supports business continuity, and meets compliance requirements across all platforms and components. Regular testing and updates to backup procedures are essential for maintaining recovery capabilities.
