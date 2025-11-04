# GitLab Project Configuration
# Copy this content to your GitLab project's settings

## CI/CD Variables

### Required Variables
```
FLUTTER_VERSION: "3.24.0"
DART_VERSION: "3.5.0"
FLUTTER_CHANNEL: "stable"
NODE_ENV: "production"

# Security (set these in GitLab project settings)
BLOCKCHAIN_API_KEY: "secure_api_key_here"
AI_API_KEY: "secure_ai_key_here"
DATABASE_URL: "postgresql://user:password@db:5432/meshapp"
REDIS_URL: "redis://redis:6379"
JWT_SECRET: "secure_jwt_secret_here"
```

### Optional Variables
```
# Deployment
FIREBASE_PROJECT_ID: "your-firebase-project"
NETLIFY_SITE_ID: "your-netlify-site"
DOCKER_REGISTRY: "registry.gitlab.com"

# Notifications
SLACK_WEBHOOK: "https://hooks.slack.com/services/..."
DISCORD_WEBHOOK: "https://discord.com/api/webhooks/..."

# Analytics
GOOGLE_ANALYTICS_ID: "GA_MEASUREMENT_ID"
SENTRY_DSN: "https://sentry-dsn-here"

# Code Quality
CODECOV_TOKEN: "codecov-token-here"
SONAR_TOKEN: "sonarcloud-token-here"
```

## Project Settings

### General Settings
- **Project name**: Katya AI REChain Mesh
- **Description**: Revolutionary Cross-Platform Mesh Network Application with AI, Blockchain, Gaming, IoT Integration
- **Visibility**: Private (for development) / Public (for open source)
- **Default branch**: main
- **Merge requests**: Require approval from maintainers

### Repository Settings
- **Deploy keys**: Add for automated deployments
- **Webhooks**: Configure for external integrations
- **Mirroring**: Set up if needed for backup/sync

### CI/CD Settings
- **Runners**: Use GitLab shared runners or custom runners
- **Auto-cancel redundant pipelines**: Enable
- **Pipeline schedules**: Weekly dependency updates
- **Protected branches**: main, develop, staging

### Monitoring
- **Error tracking**: Enable Sentry integration
- **Performance monitoring**: Enable performance insights
- **Container registry**: Enable for Docker images
- **Package registry**: Enable for Flutter packages

### Security & Compliance
- **Security scanning**: Enable SAST, DAST, Dependency scanning
- **License compliance**: Enable license scanning
- **Push rules**: Enforce commit message format
- **Branch protection**: Require status checks

## GitLab Pages (Static Site)

### Configuration
```yaml
# .gitlab-ci.yml pages job
pages:
  stage: deploy
  image: cirrusci/flutter:$FLUTTER_VERSION
  script:
    - flutter pub get
    - flutter build web --release
  artifacts:
    paths:
      - public/
  only:
    - main
  environment:
    name: production
    url: https://your-namespace.gitlab.io/katya-ai-rechain-mesh
```

## Kubernetes Integration

### K8s Manifests
```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: katya-rechain-mesh
  namespace: production
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
        image: registry.gitlab.com/your-namespace/katya-rechain-mesh:latest
        ports:
        - containerPort: 80
        env:
        - name: NODE_ENV
          value: "production"
        - name: BLOCKCHAIN_API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: blockchain-api-key
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

## Auto DevOps Configuration

### Enable Auto DevOps
1. Go to Settings > CI/CD > Auto DevOps
2. Enable Auto DevOps
3. Configure deployment target (Kubernetes, etc.)
4. Set up environment variables

### Custom Auto DevOps
```yaml
# .gitlab-ci.yml
include:
  - template: Auto-DevOps.gitlab-ci.yml

variables:
  AUTO_DEVOPS_PLATFORM_TARGET: "KUBERNETES"
  K8S_NAMESPACE: "production"
  INGRESS_HOST: "katya-ai-rechain-mesh.your-domain.com"
```

## Registry Settings

### Container Registry
- **Enable**: Settings > Repository > Container Registry
- **Cleanup policy**: Keep last 5 tags
- **Expiration policy**: Delete after 30 days

### Package Registry
- **Enable**: Settings > Repository > Package Registry
- **Packages**: Flutter packages, npm packages
- **Cleanup policy**: Remove unused packages

## Webhooks Configuration

### External Integrations
```bash
# Discord webhook for deployment notifications
curl -X POST -H 'Content-type: application/json' \
     --data '{"content":"🚀 Deployment completed successfully!"}' \
     $DISCORD_WEBHOOK

# Slack webhook for build status
curl -X POST -H 'Content-type: application/json' \
     --data '{"text":"✅ Build completed for version 1.0.0"}' \
     $SLACK_WEBHOOK
```

## Project Templates

### Issue Templates
1. **Bug Report**: Use GitHub issue template
2. **Feature Request**: Use GitHub issue template
3. **Security Issue**: Private issue template

### Merge Request Templates
1. **Standard MR**: Use GitHub PR template
2. **Hotfix MR**: Simplified template for urgent fixes
3. **Documentation MR**: Template for doc changes

## Release Management

### Automated Releases
```yaml
# .gitlab-ci.yml release job
create_release:
  stage: release
  image: alpine:latest
  script:
    - |
      if [ -n "$CI_COMMIT_TAG" ]; then
        echo "Creating release for $CI_COMMIT_TAG"
        # Create GitLab release
        curl --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
             --data "tag_name=$CI_COMMIT_TAG&name=Release $CI_COMMIT_TAG" \
             "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/releases"
      fi
  only:
    - tags
```

### Version Management
```bash
# Update version in pubspec.yaml
# Create git tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to trigger release
git push origin main --tags
```

## Monitoring & Analytics

### GitLab Insights
- **CI/CD Analytics**: Pipeline success rate, duration
- **Code Quality**: Code coverage, technical debt
- **Value Stream**: Development cycle time
- **Productivity**: Merge request analytics

### External Monitoring
```yaml
# Prometheus configuration
scrape_configs:
  - job_name: 'katya-rechain-mesh'
    static_configs:
      - targets: ['katya-rechain-mesh:9090']
    metrics_path: '/metrics'
```

## Backup Configuration

### Database Backups
```yaml
# .gitlab-ci.yml backup job
backup:
  stage: backup
  image: postgres:15-alpine
  script:
    - pg_dump -h $DATABASE_HOST -U $DATABASE_USER $DATABASE_NAME > backup_$(date +%Y%m%d).sql
  artifacts:
    paths:
      - backup_*.sql
    expire_in: 1 year
  only:
    - schedules
```

### Repository Backup
```bash
# Automated repository backup
gitlab-rake gitlab:backup:create

# Restore from backup
gitlab-rake gitlab:backup:restore BACKUP=1234567890_2025_01_26_15_0_0
```

## Compliance & Security

### Security Scanning
- **SAST**: Enable for code security analysis
- **DAST**: Enable for dynamic security testing
- **Dependency Scanning**: Check for vulnerable dependencies
- **License Scanning**: Ensure license compliance

### Compliance Settings
- **GDPR compliance**: Enable data processing controls
- **SOX compliance**: Enable audit logging
- **PCI compliance**: Enable payment card data protection (if applicable)

## Integration Examples

### Slack Integration
```yaml
# .gitlab-ci.yml notification
notify_slack:
  stage: .post
  image: curlimages/curl:latest
  script:
    - |
      if [ "$CI_JOB_STATUS" == "success" ]; then
        MESSAGE="✅ Pipeline succeeded for $CI_PROJECT_NAME"
      else
        MESSAGE="❌ Pipeline failed for $CI_PROJECT_NAME"
      fi
      curl -X POST -H 'Content-type: application/json' \
           --data "{\"text\":\"$MESSAGE - $CI_PIPELINE_URL\"}" \
           $SLACK_WEBHOOK
  when: always
```

### Jira Integration
```yaml
# .gitlab-ci.yml issue creation
create_jira_issue:
  stage: .post
  image: curlimages/curl:latest
  script:
    - |
      if [ "$CI_JOB_STATUS" == "failed" ]; then
        curl -X POST -H 'Content-type: application/json' \
             --data "{\"fields\":{\"project\":{\"key\":\"MESH\"},\"summary\":\"Build failed\",\"description\":\"Build failed in pipeline $CI_PIPELINE_ID\"}}" \
             $JIRA_API_URL
      fi
  when: on_failure
```

## Maintenance

### Scheduled Tasks
```yaml
# Weekly dependency updates
update_dependencies:
  stage: update
  image: cirrusci/flutter:$FLUTTER_VERSION
  script:
    - flutter pub upgrade
    - flutter pub outdated
  only:
    - schedules
```

### Cleanup Jobs
```yaml
# Clean old artifacts
cleanup:
  stage: cleanup
  image: curlimages/curl:latest
  script:
    - curl -X DELETE "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/jobs/artifacts?older_than=30d" \
           -H "PRIVATE-TOKEN: $GITLAB_API_TOKEN"
  only:
    - schedules
```

---

## Support

For GitLab configuration help:
- **GitLab Documentation**: https://docs.gitlab.com
- **GitLab Support**: https://support.gitlab.com
- **Community Forum**: https://forum.gitlab.com

---

*Last updated: January 2025*
