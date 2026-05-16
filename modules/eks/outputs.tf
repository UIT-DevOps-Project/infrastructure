output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  value     = aws_eks_cluster.main.certificate_authority[0].data
  sensitive = true
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}

output "node_security_group_id" {
  description = "Node SG ID — dùng để cho phép RDS nhận kết nối từ EKS"
  value       = aws_security_group.node.id
}

output "cluster_security_group_id" {
  description = "Auto-created EKS cluster SG — SG này được AWS tự gắn vào nodes khi dùng managed node groups"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "aws_lb_controller_role_arn" {
  description = "IRSA Role ARN cho aws-load-balancer-controller Helm chart"
  value       = aws_iam_role.aws_lb_controller.arn
}
