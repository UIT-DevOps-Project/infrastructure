variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

# EKS
variable "cluster_version" {
  type    = string
  default = "1.32"
}

variable "app_node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "app_node_min" {
  type    = number
  default = 2
}

variable "app_node_max" {
  type    = number
  default = 6
}

variable "app_node_desired" {
  type    = number
  default = 2
}

variable "monitor_node_instance_type" {
  type    = string
  default = "t3.large"
}

# RDS Staging
variable "rds_staging_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "rds_staging_storage" {
  type    = number
  default = 20
}

# RDS Production
variable "rds_production_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_production_storage" {
  type    = number
  default = 50
}

variable "admin_iam_arn" {
  description = "IAM ARN được cấp kubectl cluster-admin"
  type        = string
}

variable "domain" {
  description = "Root domain cho Route53 + ACM (vd: example.com). Để trống thì bỏ qua."
  type        = string
  default     = ""
}
