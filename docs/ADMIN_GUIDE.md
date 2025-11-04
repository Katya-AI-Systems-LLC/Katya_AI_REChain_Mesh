# System Administration Guide for Katya AI REChain Mesh

This comprehensive guide provides system administrators with detailed procedures for managing, maintaining, and troubleshooting the Katya AI REChain Mesh platform across all supported Git platforms and deployment environments.

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Installation and Setup](#installation-and-setup)
- [Configuration Management](#configuration-management)
- [User Management](#user-management)
- [Platform Management](#platform-management)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Backup and Recovery](#backup-and-recovery)
- [Security Administration](#security-administration)
- [Troubleshooting](#troubleshooting)
- [Performance Tuning](#performance-tuning)
- [Disaster Recovery](#disaster-recovery)

## Overview

The Katya AI REChain Mesh is a distributed platform that synchronizes repositories across multiple Git platforms including GitHub, GitLab, Bitbucket, and others. This guide covers administrative tasks for maintaining system health, managing users, configuring platforms, and ensuring optimal performance.

### Key Administrative Responsibilities

- **System Health**: Monitor performance, availability, and resource utilization
- **User Management**: Create, modify, and deactivate user accounts
- **Platform Configuration**: Set up and manage Git platform integrations
- **Security**: Implement and maintain security policies and controls
- **Backup & Recovery**: Ensure data integrity and disaster recovery capabilities
- **Performance**: Optimize system performance and resource allocation

## System Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Katya AI REChain Mesh                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   API       │  │   Mesh      │  │   AI        │          │
│  │   Gateway   │  │   Network   │  │   Engine    │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ PostgreSQL  │  │   Redis     │  │   RabbitMQ  │          │
│  │  Database   │  │   Cache     │  │   Queue     │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   GitHub    │  │   GitLab    │  │ Bitbucket   │          │
│  │ Integration │  │ Integration │  │ Integration │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Deployment Environments

#### Production Environment
- **High Availability**: Multi-region deployment with auto-scaling
- **Security**: Enterprise-grade security with encryption and access controls
- **Monitoring**: Comprehensive monitoring and alerting
- **Backup**: Automated daily backups with disaster recovery

#### Staging Environment
- **Testing**: Pre-production testing and validation
- **Performance**: Load testing and performance benchmarking
- **Integration**: Third-party service integration testing

#### Development Environment
- **Rapid Iteration**: Fast deployment cycles for development
- **Isolation**: Separate environment for development work
- **Cost Optimization**: Minimal resource allocation

## Installation and Setup

### Prerequisites

#### System Requirements

| Component | Minimum | Recommended | Production |
|-----------|---------|-------------|------------|
| **CPU** | 2 cores | 4 cores | 8+ cores |
| **RAM** | 4 GB | 8 GB | 16+ GB |
| **Storage** | 50 GB | 100 GB | 500+ GB SSD |
| **Network** | 100 Mbps | 1 Gbps | 10 Gbps |

#### Software Dependencies

```yaml
# Required software versions
dependencies:
  operating_system:
    - Ubuntu 20.04 LTS or later
    - CentOS 8 or later
    - RHEL 8 or later

  runtime:
    - Docker 20.10+
    - Docker Compose 2.0+
    - Kubernetes 1.24+

  databases:
    - PostgreSQL 13+
    - Redis 6.0+
    - RabbitMQ 3.9+

  monitoring:
    - Prometheus 2.30+
    - Grafana 8.0+
    - Elasticsearch 7.10+
```

### Installation Methods

#### Docker Installation

```bash
# Clone the repository
git clone https://github.com/katya-ai-rechain-mesh/katya-mesh.git
cd katya-mesh

# Create environment file
cp .env.example .env
# Edit .env with your configuration

# Start the system
docker-compose up -d

# Verify installation
docker-compose ps
curl http://localhost:8080/health
```

#### Kubernetes Installation

```bash
# Add Helm repository
helm repo add katya-mesh https://charts.katya-ai-rechain-mesh.com
helm repo update

# Install with Helm
helm install katya-mesh katya-mesh/katya-mesh \
  --namespace katya-mesh \
  --create-namespace \
  --set postgresql.auth.password=$(openssl rand -base64 32) \
  --set redis.auth.password=$(openssl rand -base64 32)

# Verify installation
kubectl get pods -n katya-mesh
kubectl get services -n katya-mesh
```

#### Manual Installation

```bash
# Install system dependencies
sudo apt-get update
sudo apt-get install -y postgresql redis-server rabbitmq-server nginx

# Setup PostgreSQL
sudo -u postgres createdb katya_mesh
sudo -u postgres createuser katya_user
sudo -u postgres psql -c "ALTER USER katya_user PASSWORD 'secure_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE katya_mesh TO katya_user;"

# Install Go and build application
wget https://golang.org/dl/go1.19.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Clone and build
git clone https://github.com/katya-ai-rechain-mesh/katya-mesh.git
cd katya-mesh
go mod download
go build -o katya-mesh ./cmd/server

# Configure and start service
sudo cp deploy/systemd/katya-mesh.service /etc/systemd/system/
sudo systemctl enable katya-mesh
sudo systemctl start katya-mesh
```

### Post-Installation Configuration

#### SSL/TLS Setup

```bash
# Generate SSL certificate
sudo certbot certonly --standalone -d your-domain.com

# Configure Nginx with SSL
cat > /etc/nginx/sites-available/katya-mesh << EOF
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/katya-mesh /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

#### Firewall Configuration

```bash
# Configure UFW firewall
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Verify firewall rules
sudo ufw status
```

## Configuration Management

### Configuration Files

#### Main Configuration File

```yaml
# config/katya-mesh.yaml
server:
  host: "0.0.0.0"
  port: 8080
  tls:
    enabled: true
    cert_file: "/etc/ssl/certs/katya-mesh.crt"
    key_file: "/etc/ssl/private/katya-mesh.key"

database:
  host: "localhost"
  port: 5432
  database: "katya_mesh"
  username: "katya_user"
  password: "${DB_PASSWORD}"
  ssl_mode: "require"
  max_connections: 100
  connection_timeout: "30s"

redis:
  host: "localhost"
  port: 6379
  password: "${REDIS_PASSWORD}"
  db: 0
  pool_size: 50

rabbitmq:
  host: "localhost"
  port: 5672
  username: "katya_user"
  password: "${RABBITMQ_PASSWORD}"
  vhost: "/"

platforms:
  github:
    enabled: true
    api_url: "https://api.github.com"
    token: "${GITHUB_TOKEN}"
    rate_limit: 5000

  gitlab:
    enabled: true
    api_url: "https://gitlab.com/api/v4"
    token: "${GITLAB_TOKEN}"
    rate_limit: 2000

  bitbucket:
    enabled: true
    api_url: "https://api.bitbucket.org/2.0"
    username: "${BITBUCKET_USERNAME}"
    password: "${BITBUCKET_PASSWORD}"
    rate_limit: 1000

logging:
  level: "info"
  format: "json"
  outputs:
    - "stdout"
    - "/var/log/katya-mesh/app.log"

monitoring:
  prometheus:
    enabled: true
    path: "/metrics"
  health_check:
    enabled: true
    path: "/health"
```

### Environment Variables

```bash
# .env file
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=katya_mesh
DB_USER=katya_user
DB_PASSWORD=secure_password_here
DB_SSL_MODE=require

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=secure_redis_password
REDIS_DB=0

# Message Queue
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=katya_user
RABBITMQ_PASSWORD=secure_rabbitmq_password
RABBITMQ_VHOST=/

# Platform Tokens
GITHUB_TOKEN=github_personal_access_token
GITLAB_TOKEN=gitlab_personal_access_token
BITBUCKET_USERNAME=bitbucket_username
BITBUCKET_PASSWORD=bitbucket_app_password

# Server Configuration
SERVER_HOST=0.0.0.0
SERVER_PORT=8080
SERVER_TLS_ENABLED=true
SERVER_TLS_CERT=/etc/ssl/certs/katya-mesh.crt
SERVER_TLS_KEY=/etc/ssl/private/katya-mesh.key

# Security
JWT_SECRET=very_secure_jwt_secret_key
ENCRYPTION_KEY=aes_256_encryption_key_32_chars
SESSION_SECRET=secure_session_secret

# Monitoring
PROMETHEUS_ENABLED=true
HEALTH_CHECK_ENABLED=true

# Logging
LOG_LEVEL=info
LOG_FORMAT=json
```

### Configuration Validation

```bash
# Configuration validation script
#!/bin/bash
# validate_config.sh

CONFIG_FILE="/etc/katya-mesh/config.yaml"
ENV_FILE="/etc/katya-mesh/.env"

echo "🔍 Validating configuration..."

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Check if env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Environment file not found: $ENV_FILE"
    exit 1
fi

# Validate YAML syntax
if command -v yamllint &> /dev/null; then
    yamllint "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo "❌ YAML syntax validation failed"
        exit 1
    fi
fi

# Check required environment variables
required_vars=(
    "DB_HOST" "DB_PORT" "DB_NAME" "DB_USER" "DB_PASSWORD"
    "REDIS_HOST" "REDIS_PORT" "REDIS_PASSWORD"
    "JWT_SECRET" "ENCRYPTION_KEY"
)

for var in "${required_vars[@]}"; do
    if ! grep -q "^$var=" "$ENV_FILE"; then
        echo "❌ Required environment variable missing: $var"
        exit 1
    fi
done

# Test database connection
if command -v psql &> /dev/null; then
    DB_HOST=$(grep "^DB_HOST=" "$ENV_FILE" | cut -d'=' -f2)
    DB_PORT=$(grep "^DB_PORT=" "$ENV_FILE" | cut -d'=' -f2)
    DB_NAME=$(grep "^DB_NAME=" "$ENV_FILE" | cut -d'=' -f2)
    DB_USER=$(grep "^DB_USER=" "$ENV_FILE" | cut -d'=' -f2)
    DB_PASSWORD=$(grep "^DB_PASSWORD=" "$ENV_FILE" | cut -d'=' -f2)

    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "❌ Database connection failed"
        exit 1
    fi
fi

echo "✅ Configuration validation passed"
```

## User Management

### User Account Administration

#### Creating User Accounts

```sql
-- Create new user procedure
CREATE OR REPLACE FUNCTION create_user(
    p_username VARCHAR(50),
    p_email VARCHAR(255),
    p_full_name VARCHAR(100),
    p_role VARCHAR(20) DEFAULT 'user',
    p_is_active BOOLEAN DEFAULT true
)
RETURNS UUID AS $$
DECLARE
    user_id UUID;
BEGIN
    -- Validate input
    IF LENGTH(p_username) < 3 THEN
        RAISE EXCEPTION 'Username must be at least 3 characters long';
    END IF;

    IF NOT p_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format';
    END IF;

    -- Check if username or email already exists
    IF EXISTS (SELECT 1 FROM users WHERE username = p_username) THEN
        RAISE EXCEPTION 'Username already exists';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email already exists';
    END IF;

    -- Create user
    INSERT INTO users (
        username, email, full_name, role, is_active,
        created_at, updated_at
    ) VALUES (
        p_username, p_email, p_full_name, p_role, p_is_active,
        NOW(), NOW()
    ) RETURNING id INTO user_id;

    -- Create user profile
    INSERT INTO user_profiles (user_id, created_at)
    VALUES (user_id, NOW());

    -- Log user creation
    INSERT INTO audit_logs (action, table_name, record_id, user_id, details, created_at)
    VALUES ('CREATE', 'users', user_id, user_id,
            json_build_object('username', p_username, 'email', p_email),
            NOW());

    RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### User Role Management

```sql
-- User roles and permissions
CREATE TABLE user_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default roles
INSERT INTO user_roles (name, description, permissions) VALUES
('admin', 'System Administrator', '{
    "users": {"create": true, "read": true, "update": true, "delete": true},
    "platforms": {"create": true, "read": true, "update": true, "delete": true},
    "repositories": {"create": true, "read": true, "update": true, "delete": true},
    "system": {"config": true, "monitoring": true, "backup": true}
}'),
('manager', 'Platform Manager', '{
    "users": {"create": true, "read": true, "update": true, "delete": false},
    "platforms": {"create": false, "read": true, "update": true, "delete": false},
    "repositories": {"create": true, "read": true, "update": true, "delete": true},
    "system": {"config": false, "monitoring": true, "backup": false}
}'),
('user', 'Regular User', '{
    "users": {"create": false, "read": true, "update": false, "delete": false},
    "platforms": {"create": false, "read": true, "update": false, "delete": false},
    "repositories": {"create": true, "read": true, "update": true, "delete": true},
    "system": {"config": false, "monitoring": false, "backup": false}
}');

-- Assign role to user
CREATE OR REPLACE FUNCTION assign_user_role(
    p_user_id UUID,
    p_role_name VARCHAR(50)
)
RETURNS VOID AS $$
BEGIN
    -- Validate role exists
    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE name = p_role_name) THEN
        RAISE EXCEPTION 'Role does not exist: %', p_role_name;
    END IF;

    -- Update user role
    UPDATE users
    SET role = p_role_name, updated_at = NOW()
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User not found: %', p_user_id;
    END IF;

    -- Log role assignment
    INSERT INTO audit_logs (action, table_name, record_id, user_id, details, created_at)
    VALUES ('UPDATE', 'users', p_user_id, p_user_id,
            json_build_object('field', 'role', 'old_value', (SELECT role FROM users WHERE id = p_user_id), 'new_value', p_role_name),
            NOW());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### User Authentication Management

#### Password Policies

```sql
-- Password policy enforcement
CREATE OR REPLACE FUNCTION validate_password_policy(
    p_password TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Minimum length
    IF LENGTH(p_password) < 12 THEN
        RETURN FALSE;
    END IF;

    -- Must contain uppercase letter
    IF NOT p_password ~ '[A-Z]' THEN
        RETURN FALSE;
    END IF;

    -- Must contain lowercase letter
    IF NOT p_password ~ '[a-z]' THEN
        RETURN FALSE;
    END IF;

    -- Must contain number
    IF NOT p_password ~ '[0-9]' THEN
        RETURN FALSE;
    END IF;

    -- Must contain special character
    IF NOT p_password ~ '[^A-Za-z0-9]' THEN
        RETURN FALSE;
    END IF;

    -- Check against common passwords
    IF EXISTS (SELECT 1 FROM common_passwords WHERE password = p_password) THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

#### Multi-Factor Authentication Setup

```bash
# MFA setup script
#!/bin/bash
# setup_mfa.sh

USER_ID=$1

if [ -z "$USER_ID" ]; then
    echo "Usage: $0 <user_id>"
    exit 1
fi

# Generate TOTP secret
TOTP_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

# Store TOTP secret (hashed for security)
HASHED_SECRET=$(echo -n "$TOTP_SECRET" | sha256sum | cut -d' ' -f1)

# Update user record
psql -c "
UPDATE users
SET mfa_enabled = true,
    mfa_secret = '$HASHED_SECRET',
    updated_at = NOW()
WHERE id = '$USER_ID';
"

# Generate QR code for user
qrencode -t ANSI256 "otpauth://totp/KatyaMesh:$USER_ID?secret=$TOTP_SECRET&issuer=KatyaMesh"

echo "MFA setup complete for user $USER_ID"
echo "Please scan the QR code with your authenticator app"
```

### User Activity Monitoring

```sql
-- User activity tracking
CREATE TABLE user_activity (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_user_activity_user_time (user_id, created_at),
    INDEX idx_user_activity_action (action),
    INDEX idx_user_activity_ip (ip_address)
);

-- Track user login
CREATE OR REPLACE FUNCTION track_user_login(
    p_user_id UUID,
    p_ip_address INET,
    p_user_agent TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO user_activity (
        user_id, action, ip_address, user_agent,
        metadata, created_at
    ) VALUES (
        p_user_id, 'LOGIN', p_ip_address, p_user_agent,
        json_build_object('successful', true), NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- Monitor suspicious activity
CREATE OR REPLACE FUNCTION detect_suspicious_activity()
RETURNS TABLE (
    user_id UUID,
    username VARCHAR(50),
    suspicious_events INTEGER,
    last_activity TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.username,
        COUNT(ua.id) as suspicious_events,
        MAX(ua.created_at) as last_activity
    FROM users u
    JOIN user_activity ua ON u.id = ua.user_id
    WHERE ua.created_at > NOW() - INTERVAL '24 hours'
        AND (
            ua.action IN ('FAILED_LOGIN', 'UNAUTHORIZED_ACCESS')
            OR ua.metadata->>'suspicious' = 'true'
        )
    GROUP BY u.id, u.username
    HAVING COUNT(ua.id) > 5
    ORDER BY suspicious_events DESC;
END;
$$ LANGUAGE plpgsql;
```

## Platform Management

### Git Platform Integration

#### Adding New Platforms

```sql
-- Platform management
CREATE TABLE git_platforms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    api_base_url VARCHAR(255) NOT NULL,
    auth_type VARCHAR(20) NOT NULL, -- 'token', 'oauth', 'basic'
    rate_limit INTEGER NOT NULL DEFAULT 5000,
    is_active BOOLEAN DEFAULT true,
    config JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert supported platforms
INSERT INTO git_platforms (name, display_name, api_base_url, auth_type, rate_limit) VALUES
('github', 'GitHub', 'https://api.github.com', 'token', 5000),
('gitlab', 'GitLab', 'https://gitlab.com/api/v4', 'token', 2000),
('bitbucket', 'Bitbucket', 'https://api.bitbucket.org/2.0', 'basic', 1000),
('gitea', 'Gitea', 'https://gitea.com/api/v1', 'token', 5000),
('sourceforge', 'SourceForge', 'https://sourceforge.net/rest', 'token', 1000);

-- Platform credentials
CREATE TABLE platform_credentials (
    id SERIAL PRIMARY KEY,
    platform_id INTEGER NOT NULL REFERENCES git_platforms(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- e.g., 'production', 'staging'
    credentials JSONB NOT NULL, -- Encrypted credentials
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(platform_id, name)
);
```

#### Platform Configuration

```bash
# Platform configuration script
#!/bin/bash
# configure_platform.sh

PLATFORM=$1
NAME=$2

if [ -z "$PLATFORM" ] || [ -z "$NAME" ]; then
    echo "Usage: $0 <platform> <name>"
    echo "Example: $0 github production"
    exit 1
fi

# Get platform info
PLATFORM_INFO=$(psql -t -c "
SELECT id, api_base_url, auth_type
FROM git_platforms
WHERE name = '$PLATFORM';
")

if [ -z "$PLATFORM_INFO" ]; then
    echo "❌ Platform not found: $PLATFORM"
    exit 1
fi

PLATFORM_ID=$(echo $PLATFORM_INFO | cut -d'|' -f1 | tr -d ' ')
API_URL=$(echo $PLATFORM_INFO | cut -d'|' -f2 | tr -d ' ')
AUTH_TYPE=$(echo $PLATFORM_INFO | cut -d'|' -f3 | tr -d ' ')

echo "🔧 Configuring $PLATFORM platform ($NAME)"

# Collect credentials based on auth type
case $AUTH_TYPE in
    "token")
        read -p "Enter API token: " -s TOKEN
        echo
        CREDENTIALS="{\"token\": \"$TOKEN\"}"
        ;;
    "basic")
        read -p "Enter username: " USERNAME
        read -p "Enter password/app password: " -s PASSWORD
        echo
        CREDENTIALS="{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}"
        ;;
    "oauth")
        read -p "Enter OAuth client ID: " CLIENT_ID
        read -p "Enter OAuth client secret: " -s CLIENT_SECRET
        echo
        CREDENTIALS="{\"client_id\": \"$CLIENT_ID\", \"client_secret\": \"$CLIENT_SECRET\"}"
        ;;
    *)
        echo "❌ Unsupported auth type: $AUTH_TYPE"
        exit 1
        ;;
esac

# Encrypt credentials
ENCRYPTED_CREDENTIALS=$(echo -n "$CREDENTIALS" | openssl enc -aes-256-cbc -salt -pass pass:"$ENCRYPTION_KEY" | base64 -w 0)

# Store in database
psql -c "
INSERT INTO platform_credentials (platform_id, name, credentials, is_active)
VALUES ($PLATFORM_ID, '$NAME', '$ENCRYPTED_CREDENTIALS', true)
ON CONFLICT (platform_id, name) DO UPDATE SET
    credentials = EXCLUDED.credentials,
    updated_at = NOW();
"

echo "✅ Platform $PLATFORM ($NAME) configured successfully"
```

### Repository Management

#### Repository Synchronization

```sql
-- Repository synchronization
CREATE TABLE repositories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    platform_id INTEGER NOT NULL REFERENCES git_platforms(id),
    platform_repo_id VARCHAR(100) NOT NULL,
    owner VARCHAR(100) NOT NULL,
    is_private BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    last_sync TIMESTAMP,
    sync_status VARCHAR(20) DEFAULT 'pending',
    config JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(platform_id, platform_repo_id)
);

-- Sync status tracking
CREATE TABLE sync_history (
    id SERIAL PRIMARY KEY,
    repository_id INTEGER NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
    sync_type VARCHAR(20) NOT NULL, -- 'full', 'incremental', 'metadata'
    status VARCHAR(20) NOT NULL, -- 'success', 'failed', 'partial'
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    records_processed INTEGER DEFAULT 0,
    error_message TEXT,
    metadata JSONB DEFAULT '{}',

    INDEX idx_sync_history_repo_time (repository_id, started_at),
    INDEX idx_sync_history_status (status)
);
```

#### Synchronization Monitoring

```bash
# Repository sync monitoring script
#!/bin/bash
# monitor_sync.sh

echo "🔍 Monitoring repository synchronization..."

# Check sync status
psql -c "
SELECT
    r.name as repository,
    gp.display_name as platform,
    r.last_sync,
    r.sync_status,
    CASE
        WHEN r.last_sync < NOW() - INTERVAL '1 hour' THEN 'OVERDUE'
        WHEN r.sync_status = 'failed' THEN 'FAILED'
        WHEN r.sync_status = 'running' THEN 'RUNNING'
        ELSE 'OK'
    END as health_status
FROM repositories r
JOIN git_platforms gp ON r.platform_id = gp.id
WHERE r.is_active = true
ORDER BY r.last_sync DESC NULLS FIRST;
" --table

# Check recent sync failures
echo ""
echo "Recent sync failures:"
psql -c "
SELECT
    r.name as repository,
    sh.sync_type,
    sh.started_at,
    sh.error_message
FROM sync_history sh
JOIN repositories r ON sh.repository_id = r.id
WHERE sh.status = 'failed'
    AND sh.started_at > NOW() - INTERVAL '24 hours'
ORDER BY sh.started_at DESC
LIMIT 10;
" --table

# Check sync performance
echo ""
echo "Sync performance (last 24 hours):"
psql -c "
SELECT
    DATE_TRUNC('hour', sh.started_at) as hour,
    COUNT(*) as sync_count,
    AVG(EXTRACT(EPOCH FROM (sh.completed_at - sh.started_at))) as avg_duration_seconds,
    SUM(sh.records_processed) as total_records
FROM sync_history sh
WHERE sh.status = 'success'
    AND sh.started_at > NOW() - INTERVAL '24 hours'
GROUP BY DATE_TRUNC('hour', sh.started_at)
ORDER BY hour DESC;
" --table
```

## Monitoring and Maintenance

### System Health Checks

#### Automated Health Monitoring

```bash
# System health check script
#!/bin/bash
# health_check.sh

HEALTH_STATUS="HEALTHY"
ISSUES_FOUND=()

echo "🏥 Performing system health check..."

# Check database connectivity
echo -n "Database: "
if pg_isready -h localhost -p 5432 -U katya_user -d katya_mesh >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    HEALTH_STATUS="UNHEALTHY"
    ISSUES_FOUND+=("Database connection failed")
fi

# Check Redis connectivity
echo -n "Redis: "
if redis-cli ping >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    HEALTH_STATUS="UNHEALTHY"
    ISSUES_FOUND+=("Redis connection failed")
fi

# Check RabbitMQ
echo -n "RabbitMQ: "
if rabbitmqctl status >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    HEALTH_STATUS="UNHEALTHY"
    ISSUES_FOUND+=("RabbitMQ service failed")
fi

# Check application service
echo -n "Application: "
if curl -f http://localhost:8080/health >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
    HEALTH_STATUS="UNHEALTHY"
    ISSUES_FOUND+=("Application health check failed")
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
echo -n "Disk Usage: ${DISK_USAGE}% - "
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "❌ CRITICAL"
    HEALTH_STATUS="UNHEALTHY"
    ISSUES_FOUND+=("Disk usage critical: ${DISK_USAGE}%")
elif [ "$DISK_USAGE" -gt 80 ]; then
    echo "⚠️  WARNING"
    if [ "$HEALTH_STATUS" = "HEALTHY" ]; then
        HEALTH_STATUS="WARNING"
    fi
    ISSUES_FOUND+=("Disk usage high: ${DISK_USAGE}%")
else
    echo "✅ OK"
fi

# Check memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
echo -n "Memory Usage: ${MEMORY_USAGE}% - "
if [ "$MEMORY_USAGE" -gt 90 ]; then
    echo "❌ CRITICAL"
    HEALTH_STATUS="UNHEALTHY"
    ISSUES_FOUND+=("Memory usage critical: ${MEMORY_USAGE}%")
elif [ "$MEMORY_USAGE" -gt 80 ]; then
    echo "⚠️  WARNING"
    if [ "$HEALTH_STATUS" = "HEALTHY" ]; then
        HEALTH_STATUS="WARNING"
    fi
    ISSUES_FOUND+=("Memory usage high: ${MEMORY_USAGE}%")
else
    echo "✅ OK"
fi

# Report results
echo ""
echo "Overall Health Status: $HEALTH_STATUS"

if [ ${#ISSUES_FOUND[@]} -gt 0 ]; then
    echo ""
    echo "Issues Found:"
    for issue in "${ISSUES_FOUND[@]}"; do
        echo "  - $issue"
    done
fi

# Send alert if unhealthy
if [ "$HEALTH_STATUS" = "UNHEALTHY" ]; then
    echo ""
    echo "🚨 Sending alert notification..."
    # Send alert (implement based on your alerting system)
    # send_alert "System Health Check Failed" "${ISSUES_FOUND[*]}"
fi

exit $([ "$HEALTH_STATUS" = "HEALTHY" ] && echo 0 || echo 1)
```

### Log Management

#### Log Rotation and Archiving

```bash
# Log management script
#!/bin/bash
# manage_logs.sh

LOG_DIR="/var/log/katya-mesh"
ARCHIVE_DIR="/var/log/katya-mesh/archive"
RETENTION_DAYS=30

echo "📋 Managing application logs..."

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Rotate current logs
for log_file in "$LOG_DIR"/*.log; do
    if [ -f "$log_file" ]; then
        basename=$(basename "$log_file" .log)
        timestamp=$(date +%Y%m%d_%H%M%S)

        # Compress and archive
        gzip -c "$log_file" > "$ARCHIVE_DIR/${basename}_${timestamp}.log.gz"

        # Truncate original log
        truncate -s 0 "$log_file"

        echo "Rotated: $basename"
    fi
done

# Clean up old archives
find "$ARCHIVE_DIR" -name "*.log.gz" -mtime +$RETENTION_DAYS -delete

# Compress old archives further if needed
find "$ARCHIVE_DIR" -name "*.log.gz" -mtime +7 -exec gzip -9 {} \;

echo "✅ Log management completed"
```

#### Log Analysis

```bash
# Log analysis script
#!/bin/bash
# analyze_logs.sh

LOG_FILE="/var/log/katya-mesh/app.log"
ANALYSIS_PERIOD="1 hour ago"

echo "🔍 Analyzing application logs..."

# Error summary
echo "Error Summary (last hour):"
grep -E "ERROR|FATAL" "$LOG_FILE" | \
    sed -n "/$(date -d "$ANALYSIS_PERIOD" +'%Y-%m-%d %H')/,\$p" | \
    awk '{print $4}' | sort | uniq -c | sort -nr | head -10

echo ""

# Performance metrics
echo "Slow Requests (>5s, last hour):"
grep -E "duration=[0-9]+\.[0-9]+" "$LOG_FILE" | \
    sed -n "/$(date -d "$ANALYSIS_PERIOD" +'%Y-%m-%d %H')/,\$p" | \
    awk '/duration=[5-9][0-9]*\./{print $0}' | wc -l

echo ""

# Authentication failures
echo "Failed Authentication Attempts (last hour):"
grep -i "authentication failed\|login failed" "$LOG_FILE" | \
    sed -n "/$(date -d "$ANALYSIS_PERIOD" +'%Y-%m-%d %H')/,\$p" | wc -l

echo ""

# Top error endpoints
echo "Top Error Endpoints (last hour):"
grep -E "ERROR|FATAL" "$LOG_FILE" | \
    sed -n "/$(date -d "$ANALYSIS_PERIOD" +'%Y-%m-%d %H')/,\$p" | \
    grep -oE "path=[^ ]+" | sort | uniq -c | sort -nr | head -5

echo ""

# Resource usage spikes
echo "Memory Usage Spikes (last hour):"
grep -E "memory.*[8-9][0-9]%" "$LOG_FILE" | \
    sed -n "/$(date -d "$ANALYSIS_PERIOD" +'%Y-%m-%d %H')/,\$p" | wc -l

echo "✅ Log analysis completed"
```

### Maintenance Windows

#### Scheduled Maintenance

```bash
# Maintenance window script
#!/bin/bash
# maintenance_window.sh

MAINTENANCE_DURATION="2 hours"
MAINTENANCE_MESSAGE="Scheduled maintenance: System updates and optimizations"

echo "🔧 Initiating maintenance window..."

# Enable maintenance mode
curl -X POST http://localhost:8080/api/v1/admin/maintenance \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"enabled\": true, \"message\": \"$MAINTENANCE_MESSAGE\", \"duration\": \"$MAINTENANCE_DURATION\"}"

# Wait for active connections to drain
echo "Waiting for active connections to drain..."
ACTIVE_CONNECTIONS=$(psql -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';")
while [ "$ACTIVE_CONNECTIONS" -gt 0 ]; do
    echo "Active connections: $ACTIVE_CONNECTIONS"
    sleep 30
    ACTIVE_CONNECTIONS=$(psql -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';")
done

# Perform maintenance tasks
echo "Performing maintenance tasks..."

# Update system packages
apt-get update && apt-get upgrade -y

# Vacuum database
psql -c "VACUUM ANALYZE
