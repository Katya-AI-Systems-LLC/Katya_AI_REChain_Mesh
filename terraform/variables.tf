variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "node_desired_count" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2
}

variable "node_min_count" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 5
}

variable "instance_type" {
  description = "EC2 instance type for nodes"
  type        = string
  default     = "t3.medium"
}

variable "cluster_version" {
  description = "Kubernetes cluster version"
  type        = string
  default     = "1.28"
}

