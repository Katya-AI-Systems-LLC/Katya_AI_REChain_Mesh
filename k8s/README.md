# Kubernetes Deployment

Kubernetes manifests for Katya Mesh services.

## Deploy

```bash
# Deploy broker service
kubectl apply -f mesh-broker-deployment.yaml

# Check status
kubectl get pods -l app=katya-mesh-broker
kubectl get svc katya-mesh-broker-service

# Port forward for testing
kubectl port-forward svc/katya-mesh-broker-service 8080:8080
```

## Services

- **mesh-broker-deployment.yaml** - Mesh broker deployment with Service and ConfigMap

## Scaling

```bash
# Scale up
kubectl scale deployment katya-mesh-broker --replicas=5

# Auto-scaling (requires metrics-server)
kubectl autoscale deployment katya-mesh-broker --min=2 --max=10 --cpu-percent=80
```

