output "terraform_state_bucket_id" {
  description = "The ID of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "The ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_lock_table_id" {
  description = "The ID of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.id
}

output "terraform_state_lock_table_arn" {
  description = "The ARN of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

output "mods_bucket_id" {
  description = "The ID of the S3 bucket for mods"
  value       = aws_s3_bucket.mods.id
}

output "mods_bucket_arn" {
  description = "The ARN of the S3 bucket for mods"
  value       = aws_s3_bucket.mods.arn
}

output "mods_bucket_name" {
  description = "The name of the S3 bucket for mods"
  value       = aws_s3_bucket.mods.bucket
}

output "backup_bucket_id" {
  description = "The ID of the S3 bucket for backups"
  value       = aws_s3_bucket.backups.id
}

output "backup_bucket_arn" {
  description = "The ARN of the S3 bucket for backups"
  value       = aws_s3_bucket.backups.arn
}

output "backup_bucket_name" {
  description = "The name of the S3 bucket for backups"
  value       = aws_s3_bucket.backups.bucket
}