variable "vkcloud_username" {
  description = "VK Cloud username"
  type        = string
}

variable "vkcloud_password" {
  description = "VK Cloud password"
  type        = string
  sensitive   = true
}

variable "vkcloud_project_name" {
  description = "VK Cloud project name"
  type        = string
}

variable "vkcloud_region" {
  description = "VK Cloud region"
  type        = string
  default     = "RegionOne"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "ssh_keypair_name" {
  description = "SSH keypair name"
  type        = string
}

variable "postgres_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
}
