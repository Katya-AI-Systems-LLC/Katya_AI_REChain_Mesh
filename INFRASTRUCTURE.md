# Infrastructure Overview 🏗️

Complete infrastructure setup for Katya Mesh deployment.

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Cloud Infrastructure                │
├─────────────────────────────────────────────────┤
│  AWS EKS Cluster (Kubernetes)                  │
│  ├── Mesh Broker (Go)                           │
│  ├── Mesh Broker (C++)                          │
│  ├── WebSocket Server                           │
│  ├── gRPC Services                              │
│  └── Prometheus Metrics                         │
├─────────────────────────────────────────────────┤
│  Monitoring                                     │
│  ├── Prometheus                                 │
│  └── Grafana                                    │
├─────────────────────────────────────────────────┤
│  CI/CD                                          │
│  └── GitHub Actions                             │
└─────────────────────────────────────────────────┘
```

## Components

### 1. Kubernetes (EKS)
- **Location**: `k8s/`
- **Deployment**: `mesh-broker-deployment.yaml`
- **Service**: ClusterIP service for broker
- **ConfigMap**: Configuration management

### 2. Terraform Infrastructure
- **Location**: `terraform/`
- **EKS Cluster**: Managed Kubernetes
- **VPC**: Virtual Private Cloud with subnets
- **IAM Roles**: Service and node roles
- **Node Groups**: Auto-scaling worker nodes

### 3. CI/CD Pipelines
- **Location**: `.github/workflows/`
- **Flutter**: Build and test Flutter app
- **Go**: Build and test Go services
- **C++**: Build C++ services
- **Docker**: Build and push images

### 4. Monitoring
- **Location**: `monitoring/`
- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and visualization

### 5. Services
- **Go Broker**: REST API + gRPC
- **C++ Broker**: High-performance broker
- **WebSocket**: Real-time updates
- **Metrics**: Prometheus exporter

## Quick Start

### Local Development

```bash
# Start Go broker
cd go && ./bin/mesh-broker --port 8080

# Start C++ broker
cd cpp && ./bin/mesh-broker-cpp --port 8081

# View metrics
curl http://localhost:8080/metrics
```

### Kubernetes Deployment

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Deploy services
kubectl apply -f ../k8s/

# Check status
kubectl get pods -A
```

### CI/CD

GitHub Actions automatically:
- Builds Flutter app
- Builds Go services
- Builds C++ services
- Runs tests
- Builds Docker images

## Monitoring

### Prometheus Metrics

```bash
# View metrics
curl http://localhost:8080/metrics

# Key metrics:
# - mesh_peers_total
# - mesh_peers_connected
# - mesh_messages_queue_size
# - mesh_messages_sent_total
# - mesh_success_rate
```

### Grafana Dashboard

1. Import `monitoring/grafana-dashboard.json`
2. Configure Prometheus data source
3. View real-time metrics

## Scaling

### Horizontal Scaling

```bash
# Scale deployment
kubectl scale deployment katya-mesh-broker --replicas=5

# Auto-scaling
kubectl autoscale deployment katya-mesh-broker \
  --min=2 --max=10 --cpu-percent=80
```

### Terraform Scaling

Edit `terraform/variables.tf`:
```hcl
variable "node_desired_count" {
  default = 5
}
```

## Security

- **Encryption**: AES-GCM for messages
- **Handshake**: X25519 key exchange
- **TLS**: HTTPS for API endpoints
- **IAM**: Least privilege access
- **Network**: Private subnets for nodes

## Costs

Estimated monthly costs (AWS):
- EKS Cluster: ~$73/month
- Worker Nodes (t3.medium x2): ~$60/month
- Data Transfer: Variable
- **Total**: ~$133+/month (basic setup)

## Support

- **Documentation**: See README files in each directory
- **Issues**: GitHub Issues
- **CI/CD**: Check GitHub Actions logs

