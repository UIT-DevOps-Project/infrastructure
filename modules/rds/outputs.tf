output "endpoint" {
  description = "RDS endpoint (host)"
  value       = aws_db_instance.main.address
}

output "port" {
  value = aws_db_instance.main.port
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "username" {
  value = aws_db_instance.main.username
}

output "password" {
  description = "DB password — dùng để tạo DATABASE_URL rồi seal bằng kubeseal"
  value       = random_password.db.result
  sensitive   = true
}

output "database_url" {
  description = "Full DATABASE_URL — copy và seal bằng kubeseal vào k8s-manifest"
  value       = "postgresql://${aws_db_instance.main.username}:${random_password.db.result}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive   = true
}
