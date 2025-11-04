terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

# Yandex Cloud provider configuration
provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone
}

# Kubernetes provider configuration
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
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
    yandex_resourcemanager_folder_iam_member.katya_mesh_editor,
    yandex_resourcemanager_folder_iam_member.katya_mesh_sa_editor
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
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
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
      size = 3
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
    description    = "Kubernetes API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
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
  description = "Service account for Katya Mesh cluster"
}

# IAM roles
resource "yandex_resourcemanager_folder_iam_member" "katya_mesh_editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.katya_mesh_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "katya_mesh_sa_editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.katya_mesh_sa.id}"
}

# Helm release for Katya Mesh
resource "helm_release" "katya_mesh" {
  name       = "katya-mesh"
  repository = "./kubernetes/helm"
  chart      = "katya-mesh"
  namespace  = "katya-mesh"

  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    yandex_kubernetes_node_group.katya_mesh_nodes
  ]
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

output "network_id" {
  description = "VPC Network ID"
  value       = yandex_vpc_network.katya_mesh_network.id
}
