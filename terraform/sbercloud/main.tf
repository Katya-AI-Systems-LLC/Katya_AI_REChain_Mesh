terraform {
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.35"
    }
  }
}

provider "opentelekomcloud" {
  user_name   = var.sbercloud_username
  password    = var.sbercloud_password
  domain_name = var.sbercloud_domain_name
  tenant_name = var.sbercloud_project_name
  auth_url    = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3"
  region      = var.sbercloud_region
}

# VPC
resource "opentelekomcloud_vpc_v1" "katya_mesh_vpc" {
  name = "katya-mesh-vpc"
  cidr = "10.1.0.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "katya_mesh_subnet" {
  name       = "katya-mesh-subnet"
  cidr       = "10.1.0.0/24"
  gateway_ip = "10.1.0.1"
  vpc_id     = opentelekomcloud_vpc_v1.katya_mesh_vpc.id
}

# Security Group
resource "opentelekomcloud_networking_secgroup_v2" "katya_mesh_sg" {
  name        = "katya-mesh-sg"
  description = "Security group for Katya Mesh cluster"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.katya_mesh_sg.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.katya_mesh_sg.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.katya_mesh_sg.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "mesh_ports" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 9091
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = opentelekomcloud_networking_secgroup_v2.katya_mesh_sg.id
}

# CCE (Container Cloud Engine) - Kubernetes
resource "opentelekomcloud_cce_cluster_v3" "katya_mesh_cluster" {
  name                   = "katya-mesh-cluster"
  cluster_type           = "VirtualMachine"
  flavor_id              = "cce.s1.small"
  vpc_id                 = opentelekomcloud_vpc_v1.katya_mesh_vpc.id
  subnet_id              = opentelekomcloud_vpc_subnet_v1.katya_mesh_subnet.id
  container_network_type = "overlay_l2"
  authentication_mode    = "rbac"
  kubernetes_svc_ip_range = "10.247.0.0/16"

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "opentelekomcloud_cce_node_pool_v3" "katya_mesh_node_pool" {
  cluster_id = opentelekomcloud_cce_cluster_v3.katya_mesh_cluster.id
  name       = "katya-mesh-node-pool"

  flavor_id         = "s6.large.2"
  initial_node_count = var.node_count
  min_node_count     = 1
  max_node_count     = 10
  scale_down_cooldown_time = 5
  priority           = 1

  root_volume {
    size       = 40
    volumetype = "SSD"
  }

  data_volumes {
    size       = 100
    volumetype = "SSD"
  }

  availability_zone = var.sbercloud_region
}

# RDS PostgreSQL
resource "opentelekomcloud_rds_instance_v3" "katya_mesh_postgres" {
  name              = "katya-mesh-postgres"
  flavor            = "rds.pg.c6.large.2"
  ha_replication_mode = "async"
  vpc_id            = opentelekomcloud_vpc_v1.katya_mesh_vpc.id
  subnet_id         = opentelekomcloud_vpc_subnet_v1.katya_mesh_subnet.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.katya_mesh_sg.id

  db {
    type     = "PostgreSQL"
    version  = "14"
    password = var.postgres_password
  }

  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  backup_strategy {
    start_time = "08:00-09:00"
    keep_days  = 7
  }
}

# DCS Redis
resource "opentelekomcloud_dcs_instance_v2" "katya_mesh_redis" {
  name           = "katya-mesh-redis"
  engine         = "Redis"
  engine_version = "6.0"
  capacity       = 2
  flavor         = "redis.ha.xu1.large.r2.2"
  vpc_id         = opentelekomcloud_vpc_v1.katya_mesh_vpc.id
  subnet_id      = opentelekomcloud_vpc_subnet_v1.katya_mesh_subnet.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.katya_mesh_sg.id

  backup_policy {
    backup_type = "auto"
    begin_at    = "03:00-04:00"
    period_type = "weekly"
    period_num  = 1
    backup_at   = [1]
    keep_days   = 7
  }
}

# OBS (Object Storage Service)
resource "opentelekomcloud_obs_bucket" "katya_mesh_storage" {
  bucket = "katya-mesh-storage-${random_string.bucket_suffix.result}"
  acl    = "private"

  versioning = true

  server_side_encryption {
    algorithm = "AES256"
  }

  lifecycle_rule {
    name    = "delete_old_versions"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Outputs
output "cluster_id" {
  description = "CCE Cluster ID"
  value       = opentelekomcloud_cce_cluster_v3.katya_mesh_cluster.id
}

output "cluster_external_ip" {
  description = "CCE Cluster external IP"
  value       = opentelekomcloud_cce_cluster_v3.katya_mesh_cluster.external_ip
}

output "postgres_instance_id" {
  description = "RDS PostgreSQL instance ID"
  value       = opentelekomcloud_rds_instance_v3.katya_mesh_postgres.id
}

output "postgres_address" {
  description = "RDS PostgreSQL address"
  value       = opentelekomcloud_rds_instance_v3.katya_mesh_postgres.private_ips[0]
}

output "redis_instance_id" {
  description = "DCS Redis instance ID"
  value       = opentelekomcloud_dcs_instance_v2.katya_mesh_redis.id
}

output "redis_address" {
  description = "DCS Redis address"
  value       = opentelekomcloud_dcs_instance_v2.katya_mesh_redis.private_ip
}

output "storage_bucket" {
  description = "OBS Storage bucket name"
  value       = opentelekomcloud_obs_bucket.katya_mesh_storage.bucket
}

output "vpc_id" {
  description = "VPC ID"
  value       = opentelekomcloud_vpc_v1.katya_mesh_vpc.id
}
