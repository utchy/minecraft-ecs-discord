output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "efs_id" {
  description = "The ID of the EFS file system"
  value       = module.efs.efs_id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.ecs.service_name
}

output "minecraft_task_definition_arn" {
  description = "The ARN of the Minecraft task definition"
  value       = module.ecs.task_definition_arn
}

output "discord_bot_function_name" {
  description = "The name of the Discord bot Lambda function"
  value       = module.lambda.discord_bot_function_name
}

output "discord_bot_function_arn" {
  description = "The ARN of the Discord bot Lambda function"
  value       = module.lambda.discord_bot_function_arn
}

output "auto_shutdown_function_name" {
  description = "The name of the auto-shutdown Lambda function"
  value       = module.lambda.auto_shutdown_function_name
}

output "auto_shutdown_function_arn" {
  description = "The ARN of the auto-shutdown Lambda function"
  value       = module.lambda.auto_shutdown_function_arn
}

output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "mods_bucket_name" {
  description = "The name of the S3 bucket for mods"
  value       = module.s3.mods_bucket_name
}

output "backups_bucket_name" {
  description = "The name of the S3 bucket for backups"
  value       = module.s3.backup_bucket_name
}

output "terraform_state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = module.s3.terraform_state_bucket_id
}

output "terraform_state_lock_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  value       = module.s3.terraform_state_lock_table_id
}
