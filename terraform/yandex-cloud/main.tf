terraform {
  required_version = ">= 1.0"
  
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone
}

provider "kubernetes" {
  host                   = yandex_kubernetes_cluster.katya_mesh.endpoint
  cluster_ca_certificate = base64decode(yandex_kubernetes_cluster.katya_mesh.master[0].cluster_ca_certificate)
  token                  = data.yandex_client_config.client.iam_token
}

# VPC
resource "yandex_vpc_network" "katya_mesh" {
  name = "katya-mesh-network"
}

resource "yandex_vpc_subnet" "private" {
  count          = 2
  name           = "katya-mesh-private-${count.index}"
  zone           = var.yandex_zones[count.index]
  network_id     = yandex_vpc_network.katya_mesh.id
  v4_cidr_blocks = ["10.${count.index}.0.0/24"]
}

resource "yandex_vpc_subnet" "public" {
  count          = 2
  name           = "katya-mesh-public-${count.index}"
  zone           = var.yandex_zones[count.index]
  network_id     = yandex_vpc_network.katya_mesh.id
  v4_cidr_blocks = ["10.${count.index + 10}.0/24"]
}

# Kubernetes Cluster
resource "yandex_kubernetes_cluster" "katya_mesh" {
  name        = "katya-mesh-cluster"
  description = "Katya Mesh Kubernetes Cluster"
  network_id  = yandex_vpc_network.katya_mesh.id

  master {
    regional {
      region = var.yandex_region
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.cluster.id
  node_service_account_id = yandex_iam_service_account.nodes.id

  release_channel = "REGULAR"
  network_policy_provider = "CALICO"

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.cluster,
    yandex_resourcemanager_folder_iam_binding.nodes,
  ]
}

# Kubernetes Node Group
resource "yandex_kubernetes_node_group" "katya_mesh" {
  name       = "katya-mesh-nodes"
  cluster_id = yandex_kubernetes_cluster.katya_mesh.id

  instance_template {
    platform_id = "standard-v2"
    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    network_interface {
      nat        = true
      subnet_ids = yandex_vpc_subnet.private[*].id
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count
    }
  }

  allocation_policy {
    locations {
      zone = var.yandex_zones[0]
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }
}

# Managed PostgreSQL
resource "yandex_mdb_postgresql_cluster" "katya_mesh" {
  name        = "katya-mesh-db"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.katya_mesh.id

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 20
    }
    access {
      web_sql = true
    }
    postgresql_config = {
      max_connections                   = 100
      shared_buffers                    = 16777216
      effective_cache_size              = 402653184
      maintenance_work_mem              = 67108864
      checkpoint_completion_target      = 0.9
      wal_buffers                       = 16777216
      default_statistics_target         = 100
      random_page_cost                  = 1.1
      effective_io_concurrency          = 200
      work_mem                          = 4194304
      min_wal_size                      = 16777216
      max_wal_size                      = 67108864
      max_worker_processes              = 4
      max_parallel_workers_per_gather   = 2
      max_parallel_workers              = 4
      max_parallel_maintenance_workers  = 2
    }
  }

  host {
    zone      = var.yandex_zones[0]
    subnet_id = yandex_vpc_subnet.private[0].id
  }
}

# Managed Redis
resource "yandex_mdb_redis_cluster" "katya_mesh" {
  name        = "katya-mesh-cache"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.katya_mesh.id

  config {
    password         = var.redis_password
    maxmemory_policy = "VOLATILE_LRU"
  }

  resources {
    resource_preset_id = "hm2.nano"
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  host {
    zone      = var.yandex_zones[0]
    subnet_id = yandex_vpc_subnet.private[0].id
  }
}

# IAM Service Accounts
resource "yandex_iam_service_account" "cluster" {
  name        = "katya-mesh-cluster-sa"
  description = "Service account for Kubernetes cluster"
}

resource "yandex_iam_service_account" "nodes" {
  name        = "katya-mesh-nodes-sa"
  description = "Service account for Kubernetes nodes"
}

# IAM Bindings
resource "yandex_resourcemanager_folder_iam_binding" "cluster" {
  folder_id = var.yandex_folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.cluster.id}",
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "nodes" {
  folder_id = var.yandex_folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.nodes.id}",
  ]
}

# Data sources
data "yandex_client_config" "client" {}

# Variables
variable "yandex_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yandex_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "yandex_zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "yandex_region" {
  description = "Yandex Cloud region"
  type        = string
  default     = "ru-central1"
}

variable "yandex_zones" {
  description = "Yandex Cloud zones"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b"]
}

variable "node_count" {
  description = "Number of Kubernetes nodes"
  type        = number
  default     = 2
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
  default     = ""
}

# Outputs
output "cluster_endpoint" {
  value = yandex_kubernetes_cluster.katya_mesh.endpoint
}

output "cluster_name" {
  value = yandex_kubernetes_cluster.katya_mesh.name
}

output "postgresql_host" {
  value = yandex_mdb_postgresql_cluster.katya_mesh.host[0].fqdn
}

output "redis_host" {
  value = yandex_mdb_redis_cluster.katya_mesh.host[0].fqdn
}

