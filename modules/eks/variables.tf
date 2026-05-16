variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (for ALB)"
  type        = list(string)
}

# app-nodes
variable "app_node_instance_type" {
  description = "Instance type for app node group"
  type        = string
  default     = "t3.medium"
}

variable "app_node_min" {
  description = "Minimum number of app nodes"
  type        = number
  default     = 2
}

variable "app_node_max" {
  description = "Maximum number of app nodes"
  type        = number
  default     = 6
}

variable "app_node_desired" {
  description = "Desired number of app nodes"
  type        = number
  default     = 2
}

# monitor-node
variable "monitor_node_instance_type" {
  description = "Instance type for monitor node group"
  type        = string
  default     = "t3.large"
}

variable "admin_iam_arn" {
  description = "IAM ARN được cấp quyền cluster-admin (dùng kubectl)"
  type        = string
}
