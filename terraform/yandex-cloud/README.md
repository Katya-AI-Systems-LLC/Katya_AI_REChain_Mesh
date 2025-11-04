# Yandex Cloud Infrastructure 🇷🇺

Infrastructure as Code for Katya Mesh deployment on Yandex Cloud.

## Prerequisites

- Terraform >= 1.0
- Yandex Cloud CLI configured
- kubectl installed

## Setup

```bash
# Initialize Terraform
terraform init

# Create terraform.tfvars
cat > terraform.tfvars <<EOF
yandex_token     = "your-oauth-token"
yandex_cloud_id  = "your-cloud-id"
yandex_folder_id = "your-folder-id"
redis_password    = "your-redis-password"
EOF

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

## Resources

- **Kubernetes Cluster** - Managed Kubernetes (Yandex Managed Service for Kubernetes)
- **Node Groups** - Auto-scaling worker nodes
- **PostgreSQL** - Managed PostgreSQL cluster
- **Redis** - Managed Redis cluster
- **VPC** - Virtual Private Cloud with subnets
- **IAM** - Service accounts and permissions

## Deployment

After applying Terraform:

```bash
# Get cluster credentials
yc managed-kubernetes cluster get-credentials --id $(terraform output -raw cluster_id)

# Deploy services
kubectl apply -f ../../k8s/

# Check status
kubectl get nodes
kubectl get pods -A
```

## Features

- **Российская облачная инфраструктура** - Yandex Cloud
- **Managed Services** - PostgreSQL и Redis
- **Auto-scaling** - Автоматическое масштабирование
- **High Availability** - Высокая доступность
- **Security** - Безопасность по умолчанию

## Costs

Estimated monthly costs (Yandex Cloud):
- Kubernetes Cluster: ~2000₽/мес
- Worker Nodes (s2.micro x2): ~6000₽/мес
- PostgreSQL: ~2000₽/мес
- Redis: ~1500₽/мес
- **Total**: ~11500₽/мес (базовая настройка)

## Support

- [Yandex Cloud Documentation](https://cloud.yandex.ru/docs/)
- [Terraform Provider](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)

