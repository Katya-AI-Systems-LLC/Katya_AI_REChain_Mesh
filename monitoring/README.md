# Monitoring & Metrics

Prometheus and Grafana monitoring setup for Katya Mesh.

## Prometheus

Metrics are exposed on `/metrics` endpoint:

```bash
curl http://localhost:8080/metrics
```

Available metrics:
- `mesh_peers_total` - Total discovered peers
- `mesh_peers_connected` - Connected peers
- `mesh_messages_queue_size` - Messages in queue
- `mesh_messages_sent_total` - Total messages sent
- `mesh_messages_delivered_total` - Total messages delivered
- `mesh_messages_failed_total` - Total failed messages
- `mesh_success_rate` - Delivery success rate
- `mesh_http_requests_total` - HTTP requests by method/endpoint
- `mesh_http_request_duration_seconds` - HTTP request duration

## Grafana

Import `grafana-dashboard.json` into Grafana:

1. Go to Grafana → Dashboards → Import
2. Upload `grafana-dashboard.json`
3. Configure Prometheus data source

## Setup

```bash
# Run Prometheus (docker)
docker run -d -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Run Grafana (docker)
docker run -d -p 3000:3000 grafana/grafana

# Access
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

## Kubernetes

For Kubernetes deployment:

```yaml
# prometheus-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  ports:
  - port: 9090
    targetPort: 9090
  selector:
    app: prometheus
```

