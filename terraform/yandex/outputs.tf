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

output "registry_address" {
  description = "Container Registry address"
  value       = yandex_container_registry.katya_mesh_registry.id
}

output "postgres_cluster_id" {
  description = "PostgreSQL Cluster ID"
  value       = yandex_mdb_postgresql_cluster.katya_mesh_postgres.id
}

output "postgres_host" {
  description = "PostgreSQL cluster host"
  value       = yandex_mdb_postgresql_cluster.katya_mesh_postgres.host[0].fqdn
}

output "postgres_port" {
  description = "PostgreSQL port"
  value       = 6432
}

output "redis_cluster_id" {
  description = "Redis Cluster ID"
  value       = yandex_mdb_redis_cluster.katya_mesh_redis.id
}

output "redis_host" {
  description = "Redis cluster host"
  value       = yandex_mdb_redis_cluster.katya_mesh_redis.host
}

output "redis_port" {
  description = "Redis port"
  value       = 6379
}

output "storage_bucket_name" {
  description = "Object Storage Bucket Name"
  value       = yandex_storage_bucket.katya_mesh_storage.bucket
}

output "network_id" {
  description = "VPC Network ID"
  value       = yandex_vpc_network.katya_mesh_network.id
}

output "subnet_id" {
  description = "VPC Subnet ID"
  value       = yandex_vpc_subnet.katya_mesh_subnet.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = yandex_vpc_security_group.katya_mesh_sg.id
}
