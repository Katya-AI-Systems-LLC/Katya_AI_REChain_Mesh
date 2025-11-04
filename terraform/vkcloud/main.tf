terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53"
    }
  }
}

provider "openstack" {
  auth_url    = "https://infra.mail.ru:35357/v3"
  domain_name = "users"
  tenant_name = var.vkcloud_project_name
  user_name   = var.vkcloud_username
  password    = var.vkcloud_password
  region      = var.vkcloud_region
}

# VPC Network
resource "openstack_networking_network_v2" "katya_mesh_network" {
  name           = "katya-mesh-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "katya_mesh_subnet" {
  name       = "katya-mesh-subnet"
  network_id = openstack_networking_network_v2.katya_mesh_network.id
  cidr       = "10.1.0.0/16"
  ip_version = 4
}

# Security Group
resource "openstack_networking_secgroup_v2" "katya_mesh_sg" {
  name        = "katya-mesh-sg"
  description = "Security group for Katya Mesh cluster"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.katya_mesh_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.katya_mesh_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.katya_mesh_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "mesh_ports" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 9091
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.katya_mesh_sg.id
}

# Router
resource "openstack_networking_router_v2" "katya_mesh_router" {
  name                = "katya-mesh-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

resource "openstack_networking_router_interface_v2" "katya_mesh_router_interface" {
  router_id = openstack_networking_router_v2.katya_mesh_router.id
  subnet_id = openstack_networking_subnet_v2.katya_mesh_subnet.id
}

# Kubernetes Cluster (using Magnum)
resource "openstack_containerinfra_clustertemplate_v1" "katya_mesh_template" {
  name                  = "katya-mesh-template"
  image                 = "Fedora-CoreOS-32"
  external_network_id   = data.openstack_networking_network_v2.external_network.id
  master_flavor_id      = data.openstack_compute_flavor_v2.master_flavor.id
  flavor_id             = data.openstack_compute_flavor_v2.worker_flavor.id
  docker_volume_size    = 50
  network_driver        = "calico"
  volume_driver         = "cinder"
  coe                   = "kubernetes"
  tls_disabled          = false
  public                = false
  registry_enabled      = true
  master_lb_enabled     = true
  floating_ip_enabled   = true
}

resource "openstack_containerinfra_cluster_v1" "katya_mesh_cluster" {
  name            = "katya-mesh-cluster"
  cluster_template_id = openstack_containerinfra_clustertemplate_v1.katya_mesh_template.id
  master_count    = 1
  node_count      = var.node_count
  keypair         = var.ssh_keypair_name
  floating_ip_enabled = true
}

# VMs for additional services
resource "openstack_compute_instance_v2" "katya_mesh_postgres" {
  name            = "katya-mesh-postgres"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_id       = data.openstack_compute_flavor_v2.small_flavor.id
  key_pair        = var.ssh_keypair_name
  security_groups = [openstack_networking_secgroup_v2.katya_mesh_sg.name]

  network {
    uuid = openstack_networking_network_v2.katya_mesh_network.id
  }

  user_data = <<-EOF
    #cloud-config
    packages:
      - postgresql
      - postgresql-contrib
    runcmd:
      - sudo systemctl enable postgresql
      - sudo systemctl start postgresql
      - sudo -u postgres createdb katya_mesh
      - sudo -u postgres psql -c "CREATE USER katya_mesh_user WITH PASSWORD '${var.postgres_password}';"
      - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE katya_mesh TO katya_mesh_user;"
  EOF
}

resource "openstack_compute_instance_v2" "katya_mesh_redis" {
  name            = "katya-mesh-redis"
  image_id        = data.openstack_images_image_v2.ubuntu.id
  flavor_id       = data.openstack_compute_flavor_v2.small_flavor.id
  key_pair        = var.ssh_keypair_name
  security_groups = [openstack_networking_secgroup_v2.katya_mesh_sg.name]

  network {
    uuid = openstack_networking_network_v2.katya_mesh_network.id
  }

  user_data = <<-EOF
    #cloud-config
    packages:
      - redis-server
    runcmd:
      - sudo systemctl enable redis-server
      - sudo systemctl start redis-server
  EOF
}

# Object Storage Container
resource "openstack_objectstorage_container_v1" "katya_mesh_storage" {
  name = "katya-mesh-storage"
  container_read = ".r:*"
  container_write = "katya-mesh-user"
}

# Data sources
data "openstack_networking_network_v2" "external_network" {
  name = "external-network"
}

data "openstack_compute_flavor_v2" "master_flavor" {
  name = "m1.medium"
}

data "openstack_compute_flavor_v2" "worker_flavor" {
  name = "m1.small"
}

data "openstack_compute_flavor_v2" "small_flavor" {
  name = "m1.tiny"
}

data "openstack_images_image_v2" "ubuntu" {
  name = "Ubuntu 20.04"
}

# Outputs
output "cluster_id" {
  description = "Kubernetes Cluster ID"
  value       = openstack_containerinfra_cluster_v1.katya_mesh_cluster.id
}

output "cluster_api_address" {
  description = "Kubernetes API address"
  value       = openstack_containerinfra_cluster_v1.katya_mesh_cluster.api_address
}

output "postgres_ip" {
  description = "PostgreSQL server IP"
  value       = openstack_compute_instance_v2.katya_mesh_postgres.access_ip_v4
}

output "redis_ip" {
  description = "Redis server IP"
  value       = openstack_compute_instance_v2.katya_mesh_redis.access_ip_v4
}

output "storage_container" {
  description = "Object Storage Container Name"
  value       = openstack_objectstorage_container_v1.katya_mesh_storage.name
}

output "network_id" {
  description = "Network ID"
  value       = openstack_networking_network_v2.katya_mesh_network.id
}
