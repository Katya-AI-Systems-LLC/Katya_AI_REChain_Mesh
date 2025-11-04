variable "sbercloud_username" {
  description = "SberCloud username"
  type        = string
}

variable "sbercloud_password" {
  description = "SberCloud password"
  type        = string
  sensitive   = true
}

variable "sbercloud_domain_name" {
  description = "SberCloud domain name"
  type        = string
}

variable "sbercloud_project_name" {
  description = "SberCloud project name"
  type        = string
}

variable "sbercloud_region" {
  description = "SberCloud region"
  type        = string
  default     = "ru-moscow-1"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "postgres_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
}
