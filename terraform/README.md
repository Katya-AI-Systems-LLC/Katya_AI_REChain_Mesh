# Terraform Infrastructure

Infrastructure as Code for Katya Mesh deployment on AWS EKS.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- kubectl installed

## Setup

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure
terraform destroy
```

## Variables

Edit `terraform.tfvars` or set via environment:

```bash
export TF_VAR_aws_region="us-east-1"
export TF_VAR_node_desired_count=3
```

## Deployment

After applying Terraform:

```bash
# Get cluster credentials
aws eks update-kubeconfig --name katya-mesh-cluster --region us-east-1

# Deploy services
kubectl apply -f ../k8s/

# Check status
kubectl get nodes
kubectl get pods -A
```

## Architecture

- **EKS Cluster** - Managed Kubernetes cluster
- **VPC** - Virtual Private Cloud with public/private subnets
- **Node Groups** - Auto-scaling worker nodes
- **IAM Roles** - Service and node roles

## Monitoring

- Prometheus metrics exposed on `/metrics`
- Grafana dashboards (see `monitoring/`)

