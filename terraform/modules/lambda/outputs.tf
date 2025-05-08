output "discord_bot_function_name" {
  description = "The name of the Discord bot Lambda function"
  value       = aws_lambda_function.discord_bot.function_name
}

output "discord_bot_function_arn" {
  description = "The ARN of the Discord bot Lambda function"
  value       = aws_lambda_function.discord_bot.arn
}

output "auto_shutdown_function_name" {
  description = "The name of the auto-shutdown Lambda function"
  value       = aws_lambda_function.auto_shutdown.function_name
}

output "auto_shutdown_function_arn" {
  description = "The ARN of the auto-shutdown Lambda function"
  value       = aws_lambda_function.auto_shutdown.arn
}

output "discord_bot_ecr_repository_url" {
  description = "The URL of the Discord bot ECR repository"
  value       = aws_ecr_repository.discord_bot.repository_url
}

output "auto_shutdown_ecr_repository_url" {
  description = "The URL of the auto-shutdown ECR repository"
  value       = aws_ecr_repository.auto_shutdown.repository_url
}

output "lambda_role_arn" {
  description = "The ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda.arn
}

output "lambda_security_group_id" {
  description = "The ID of the Lambda security group"
  value       = aws_security_group.lambda.id
}