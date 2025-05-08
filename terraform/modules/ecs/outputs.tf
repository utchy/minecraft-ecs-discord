output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.minecraft.name
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.minecraft.arn
}

output "service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.minecraft.name
}

output "service_arn" {
  description = "The ARN of the ECS service"
  value       = aws_ecs_service.minecraft.id
}

output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = aws_ecs_task_definition.minecraft.arn
}

output "task_definition_family" {
  description = "The family of the task definition"
  value       = aws_ecs_task_definition.minecraft.family
}

output "security_group_id" {
  description = "The ID of the security group for the Minecraft server"
  value       = aws_security_group.minecraft.id
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.minecraft.name
}