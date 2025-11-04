terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
  }
}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone
}

# VPC Network
resource "yandex_vpc_network" "katya_mesh_network" {
  name        = "katya-mesh-network"
  description = "Network for Katya Mesh infrastructure"
}

# VPC Subnet
resource "yandex_vpc_subnet" "katya_mesh_subnet" {
  name           = "katya-mesh-subnet"
  description    = "Subnet for Katya Mesh cluster"
  v4_cidr_blocks = ["10.1.0.0/16"]
  zone           = var.yandex_zone
  network_id     = yandex_vpc_network.katya_mesh_network.id
}

# Security Group
resource "yandex_vpc_security_group" "katya_mesh_sg" {
  name        = "katya-mesh-sg"
  description = "Security group for Katya Mesh cluster"
  network_id  = yandex_vpc_network.katya_mesh_network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "Mesh ports"
    v4_cidr_blocks = ["10.1.0.0/16"]
    from_port      = 8080
    to_port        = 9091
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Service Account
resource "yandex_iam_service_account" "katya_mesh_sa" {
  name        = "katya-mesh-sa"
  description = "Service account for Katya Mesh infrastructure"
}

# IAM roles
resource "yandex_resourcemanager_folder_iam_member" "katya_mesh_editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.katya_mesh_sa.id}"
}

# Yandex Container Registry
resource "yandex_container_registry" "katya_mesh_registry" {
  name        = "katya-mesh-registry"
  description = "Container registry for Katya Mesh images"
  folder_id   = var.yandex_folder_id

  labels = {
    environment = "production"
    project     = "katya-mesh"
  }
}

# Yandex Kubernetes Cluster
resource "yandex_kubernetes_cluster" "katya_mesh_cluster" {
  name        = "katya-mesh-cluster"
  description = "Kubernetes cluster for Katya AI REChain Mesh"

  network_id = yandex_vpc_network.katya_mesh_network.id

  master {
    version = "1.27"
    zonal {
      zone      = var.yandex_zone
      subnet_id = yandex_vpc_subnet.katya_mesh_subnet.id
    }

    public_ip = true

    security_group_ids = [yandex_vpc_security_group.katya_mesh_sg.id]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.katya_mesh_sa.id
  node_service_account_id = yandex_iam_service_account.katya_mesh_sa.id

  release_channel = "STABLE"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.katya_mesh_editor
  ]
}

# Kubernetes Node Group
resource "yandex_kubernetes_node_group" "katya_mesh_nodes" {
  cluster_id  = yandex_kubernetes_cluster.katya_mesh_cluster.id
  name        = "katya-mesh-nodes"
  description = "Node group for Katya Mesh cluster"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      security_group_ids = [yandex_vpc_security_group.katya_mesh_sg.id]
      subnet_ids         = [yandex_vpc_subnet.katya_mesh_subnet.id]
    }

    resources {
      memory = var.node_memory
      cores  = var.node_cores
    }

    boot_disk {
      type = "network-hdd"
      size = var.disk_size
    }

    scheduling_policy {
      preemptible = false
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
    location {
      zone = var.yandex_zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      start_time = "15:00"
      duration   = "3h"
    }
  }
}

# Yandex Managed PostgreSQL
resource "yandex_mdb_postgresql_cluster" "katya_mesh_postgres" {
  name        = "katya-mesh-postgres"
  description = "PostgreSQL cluster for Katya Mesh data storage"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.katya_mesh_network.id

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }
  }

  host {
    zone      = var.yandex_zone
    subnet_id = yandex_vpc_subnet.katya_mesh_subnet.id
  }
}

resource "yandex_mdb_postgresql_database" "katya_mesh_db" {
  cluster_id = yandex_mdb_postgresql_cluster.katya_mesh_postgres.id
  name       = "katya_mesh"
  owner      = "katya_mesh_user"
}

resource "yandex_mdb_postgresql_user" "katya_mesh_user" {
  cluster_id = yandex_mdb_postgresql_cluster.katya_mesh_postgres.id
  name       = "katya_mesh_user"
  password   = var.postgres_password
}

# Yandex Managed Redis
resource "yandex_mdb_redis_cluster" "katya_mesh_redis" {
  name        = "katya-mesh-redis"
  description = "Redis cluster for Katya Mesh caching"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.katya_mesh_network.id

  config {
    version = "7.0"
    resources {
      resource_preset_id = "b1.micro"
      disk_type_id       = "network-hdd"
      disk_size          = 8
    }
  }

  host {
    zone      = var.yandex_zone
    subnet_id = yandex_vpc_subnet.katya_mesh_subnet.id
  }
}

# Yandex Object Storage Bucket
resource "yandex_storage_bucket" "katya_mesh_storage" {
  bucket = "katya-mesh-storage-${var.yandex_folder_id}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Outputs
output "cluster_id" {
  description = "Yandex Kubernetes Cluster ID"
  value       = yandex_kubernetes_cluster.katya_mesh_cluster.id
}

output "cluster_external_v4_endpoint" {
  description = "Kubernetes cluster external endpoint"
  value       = yandex_kubernetes_cluster.katya_mesh_cluster.master[0].external_v4_endpoint
}

output "registry_id" {
  description = "Container Registry ID"
  value       = yandex_container_registry.katya_mesh_registry.id
}

output "postgres_cluster_id" {
  description = "PostgreSQL Cluster ID"
  value       = yandex_mdb_postgresql_cluster.katya_mesh_postgres.id
}

output "redis_cluster_id" {
  description = "Redis Cluster ID"
  value       = yandex_mdb_redis_cluster.katya_mesh_redis.id
}

output "storage_bucket_name" {
  description = "Object Storage Bucket Name"
  value       = yandex_storage_bucket.katya_mesh_storage.bucket
}

output "network_id" {
  description = "VPC Network ID"
  value       = yandex_vpc_network.katya_mesh_network.id
}
