output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "The name of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task IAM role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "The name of the ECS task IAM role"
  value       = aws_iam_role.ecs_task.name
}

output "lambda_role_arn" {
  description = "The ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  description = "The name of the Lambda IAM role"
  value       = aws_iam_role.lambda.name
}

output "cloudwatch_events_role_arn" {
  description = "The ARN of the CloudWatch Events IAM role"
  value       = aws_iam_role.cloudwatch_events.arn
}

output "cloudwatch_events_role_name" {
  description = "The name of the CloudWatch Events IAM role"
  value       = aws_iam_role.cloudwatch_events.name
}