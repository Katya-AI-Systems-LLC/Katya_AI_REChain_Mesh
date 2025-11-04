output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.katya_mesh.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.katya_mesh.name
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.katya_mesh.vpc_config[0].cluster_security_group_id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

