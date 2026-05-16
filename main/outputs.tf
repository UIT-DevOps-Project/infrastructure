output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "aws_lb_controller_role_arn" {
  description = "Dùng trong Helm values của aws-load-balancer-controller"
  value       = module.eks.aws_lb_controller_role_arn
}

# RDS Staging — dùng để tạo SealedSecret
output "rds_staging_database_url" {
  description = "DATABASE_URL cho staging — chạy: terraform output -raw rds_staging_database_url"
  value       = module.rds_staging.database_url
  sensitive   = true
}

# RDS Production — dùng để tạo SealedSecret
output "rds_production_database_url" {
  description = "DATABASE_URL cho production — chạy: terraform output -raw rds_production_database_url"
  value       = module.rds_production.database_url
  sensitive   = true
}

output "acm_certificate_arn" {
  description = "Dùng trong ALB Ingress annotation: alb.ingress.kubernetes.io/certificate-arn"
  value       = var.domain != "" ? module.acm[0].certificate_arn : "domain chưa được cấu hình"
}

output "route53_nameservers" {
  description = "Trỏ domain về các nameserver này ở nhà cung cấp domain"
  value       = var.domain != "" ? module.acm[0].nameservers : []
}
