# Deployment Guide

This guide covers deployment of Katya AI REChain Mesh to various platforms and environments.

## Table of Contents

- [Quick Deploy](#quick-deploy)
- [Platform Deployment](#platform-deployment)
- [Container Deployment](#container-deployment)
- [CI/CD Deployment](#cicd-deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## Quick Deploy

### Prerequisites

- Flutter SDK 3.24.0+
- Docker (for containerized deployment)
- Access to target platform

### One-Command Deploy

```bash
# Deploy web version to Firebase
make deploy-web

# Deploy mobile apps
make deploy-android
make deploy-ios

# Deploy full stack with Docker
make docker-deploy
```

## Platform Deployment

### Web Deployment

#### Firebase Hosting
```bash
# Build web app
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting

# Or use script
bash scripts/deploy_web.sh
```

#### Netlify
```bash
# Build and deploy
bash scripts/deploy_netlify.sh
```

#### GitHub Pages
```yaml
# .github/workflows/deploy.yml
- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./build/web
```

### Mobile Deployment

#### Android (Google Play)
```bash
# Build release bundle
flutter build appbundle --release

# Deploy with Fastlane
fastlane android deploy
```

#### iOS (App Store)
```bash
# Build for release
flutter build ios --release

# Deploy with Fastlane
fastlane ios deploy
```

### Desktop Deployment

#### Linux (Snap Store)
```bash
# Build Linux package
flutter build linux --release

# Create snap package
snapcraft

# Upload to Snap Store
snapcraft upload katya-rechain-mesh_1.0.0_amd64.snap --release=stable
```

#### Windows (Microsoft Store)
```bash
# Build Windows package
flutter build windows --release

# Create MSIX package
flutter pub run msix:create

# Submit to Microsoft Store
# Upload .msix file through Partner Center
```

#### macOS (Mac App Store)
```bash
# Build macOS package
flutter build macos --release

# Code sign and notarize
codesign --deep --force --verbose --sign "Developer ID" build/macos/Build/Products/Release/Katya\ AI\ REChain\ Mesh.app

# Create DMG
create-dmg build/macos/Build/Products/Release/Katya\ AI\ REChain\ Mesh.app

# Submit to App Store
xcrun altool --upload-app -f Katya-AI-REChain-Mesh.dmg -t macos -u username -p password
```

## Container Deployment

### Docker

#### Build Images
```bash
# Build all images
docker build -t katya-rechain-mesh .
docker build -t katya-rechain-mesh-backend backend/

# Build for specific platforms
docker buildx build --platform linux/amd64,linux/arm64 -t katya-rechain-mesh .
```

#### Run with Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Scale services
docker-compose up -d --scale flutter-web=3
```

#### Kubernetes Deployment
```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: katya-rechain-mesh
spec:
  replicas: 3
  selector:
    matchLabels:
      app: katya-rechain-mesh
  template:
    metadata:
      labels:
        app: katya-rechain-mesh
    spec:
      containers:
      - name: app
        image: katya-rechain-mesh:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Cloud Platforms

#### Google Cloud Run
```bash
# Build and deploy
gcloud builds submit --tag gcr.io/PROJECT_ID/katya-rechain-mesh
gcloud run deploy --image gcr.io/PROJECT_ID/katya-rechain-mesh --platform managed
```

#### AWS ECS Fargate
```bash
# Build and push to ECR
aws ecr create-repository --repository-name katya-rechain-mesh
docker build -t katya-rechain-mesh .
docker tag katya-rechain-mesh:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/katya-rechain-mesh:latest
aws ecr get-login-password | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/katya-rechain-mesh:latest

# Deploy to ECS
aws ecs create-service --cluster katya-cluster --service-name katya-rechain-mesh --task-definition katya-rechain-mesh
```

#### Azure Container Instances
```bash
# Create resource group
az group create --name katya-rg --location eastus

# Deploy container
az container create --resource-group katya-rg --name katya-rechain-mesh \
  --image katya-rechain-mesh:latest --ports 80 \
  --environment-variables NODE_ENV=production
```

## CI/CD Deployment

### GitHub Actions

#### Automatic Deployment
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: |
          echo "Deploying version ${GITHUB_REF#refs/tags/}"
          # Deploy logic here
```

#### Manual Deployment
```yaml
# .github/workflows/manual-deploy.yml
name: Manual Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: bash scripts/deploy_${{ github.event.inputs.environment }}.sh
```

### GitLab CI/CD

#### Auto-deployment
```yaml
# .gitlab-ci.yml
deploy_staging:
  stage: deploy
  script:
    - echo "Deploying to staging..."
    - bash scripts/deploy_staging.sh
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - echo "Deploying to production..."
    - bash scripts/deploy_production.sh
  only:
    - main
  when: manual
```

## Environment Configuration

### Development
```bash
# .env.dev
DEBUG=true
LOG_LEVEL=verbose
API_URL=http://localhost:8080
BLOCKCHAIN_NETWORK=testnet
```

### Staging
```bash
# .env.staging
DEBUG=false
LOG_LEVEL=info
API_URL=https://staging-api.katya-ai.com
BLOCKCHAIN_NETWORK=testnet
```

### Production
```bash
# .env.prod
DEBUG=false
LOG_LEVEL=error
API_URL=https://api.katya-ai.com
BLOCKCHAIN_NETWORK=mainnet
```

## Database Migration

### PostgreSQL
```sql
-- Migration script
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### MongoDB
```javascript
// Migration script
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ createdAt: 1 });
```

## Monitoring

### Health Checks
```bash
# Application health
curl https://your-domain.com/health

# Database health
curl https://your-domain.com/api/health/db

# External services health
curl https://your-domain.com/api/health/external
```

### Logging
```yaml
# docker-compose.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Metrics
```yaml
# Prometheus configuration
scrape_configs:
  - job_name: 'katya-rechain-mesh'
    static_configs:
      - targets: ['app:9090']
```

## Security

### SSL/TLS
```bash
# Generate SSL certificate
certbot certonly --standalone -d your-domain.com

# Configure nginx with SSL
# See docker/nginx-ssl.conf
```

### Secrets Management
```yaml
# GitHub Secrets
secrets:
  - name: BLOCKCHAIN_API_KEY
  - name: DATABASE_URL
  - name: REDIS_URL
  - name: JWT_SECRET
```

### Firewall Rules
```bash
# UFW (Ubuntu)
ufw allow 80
ufw allow 443
ufw allow 22  # SSH
ufw --force enable

# Cloud firewall
# Configure security groups in your cloud provider
```

## Performance Optimization

### Caching
```yaml
# Redis configuration
services:
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
```

### CDN
```bash
# CloudFlare configuration
# Set up page rules for static assets caching
# Enable compression and minification
```

### Database Optimization
```sql
-- Create indexes
CREATE INDEX CONCURRENTLY idx_messages_user_id ON messages(user_id);
CREATE INDEX CONCURRENTLY idx_messages_timestamp ON messages(timestamp DESC);

-- Enable query optimization
EXPLAIN ANALYZE SELECT * FROM messages WHERE user_id = ? ORDER BY timestamp DESC LIMIT 50;
```

## Backup and Recovery

### Automated Backups
```bash
# Daily database backup
0 2 * * * pg_dump -h db-host -U postgres meshapp > /backups/backup_$(date +\%Y\%m\%d).sql

# Upload to cloud storage
aws s3 cp /backups/backup_$(date +\%Y\%m\%d).sql s3://katya-backups/
```

### Recovery
```bash
# Restore from backup
psql -h db-host -U postgres meshapp < backup_20250126.sql

# Verify data integrity
psql -h db-host -U postgres meshapp -c "SELECT COUNT(*) FROM users;"
```

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clear Flutter cache
flutter clean
flutter pub cache repair
flutter doctor

# Check dependencies
flutter pub outdated
flutter pub upgrade
```

#### Runtime Errors
```bash
# Check logs
docker-compose logs app
kubectl logs -f deployment/katya-rechain-mesh

# Monitor resources
docker stats
kubectl top pods
```

#### Network Issues
```bash
# Test connectivity
curl -I https://your-domain.com/health
telnet your-domain.com 80

# Check DNS
nslookup your-domain.com
```

### Emergency Procedures

#### Rollback Deployment
```bash
# GitHub Actions
# Cancel current workflow and deploy previous version

# Kubernetes
kubectl rollout undo deployment/katya-rechain-mesh

# Docker
docker-compose down
docker-compose up -d app=v1.0.0
```

#### Database Recovery
```bash
# Emergency restore
psql -h db-host -U postgres meshapp < emergency_backup.sql

# Verify recovery
psql -h db-host -U postgres meshapp -c "SELECT COUNT(*) FROM critical_table;"
```

## Support

For deployment support:
- **Issues**: [GitHub Issues](https://github.com/katya-ai-rechain-mesh/issues)
- **Discussions**: [GitHub Discussions](https://github.com/katya-ai-rechain-mesh/discussions)
- **Email**: devops@katya-ai.com

## Version History

- **v1.0.0**: Initial multi-platform deployment
- **v0.9.0**: Beta testing and optimization
- **v0.1.0**: Development and staging

---

*Last updated: January 2025*
