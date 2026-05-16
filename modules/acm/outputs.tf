output "certificate_arn" {
  description = "ACM cert ARN — dùng trong ALB Ingress annotation"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "nameservers" {
  description = "Trỏ domain về các nameserver này ở nhà cung cấp domain"
  value       = aws_route53_zone.main.name_servers
}
