# Katya Mesh Helm Chart

Helm chart for deploying Katya Mesh on Kubernetes.

## Installation

```bash
# Add Helm repo (if needed)
helm repo add katya-mesh https://charts.katya-mesh.ru
helm repo update

# Install with default values
helm install katya-mesh ./helm/katya-mesh

# Install with custom values
helm install katya-mesh ./helm/katya-mesh \
  --set replicaCount=5 \
  --set image.tag=v1.0.0
```

## Configuration

### Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `3` |
| `image.repository` | Image repository | `katya-mesh-go` |
| `image.tag` | Image tag | `latest` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `resources.requests` | Resource requests | `cpu: 100m, memory: 128Mi` |
| `resources.limits` | Resource limits | `cpu: 500m, memory: 512Mi` |
| `autoscaling.enabled` | Enable autoscaling | `true` |
| `autoscaling.minReplicas` | Minimum replicas | `2` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `postgresql.enabled` | Enable PostgreSQL | `true` |
| `redis.enabled` | Enable Redis | `true` |

## Upgrade

```bash
helm upgrade katya-mesh ./helm/katya-mesh
```

## Uninstall

```bash
helm uninstall katya-mesh
```

