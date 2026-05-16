output "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform state — copy vào main/backend.tf"
  value       = aws_s3_bucket.tfstate.bucket
}

output "tfstate_lock_table" {
  description = "DynamoDB table name for state locking — copy vào main/backend.tf"
  value       = aws_dynamodb_table.tfstate_lock.name
}
