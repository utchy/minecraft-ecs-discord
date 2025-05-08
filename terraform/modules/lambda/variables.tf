variable "project_name" {
  description = "Name of the project, used as a prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets where Lambda functions will run"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "discord_bot_token_parameter_name" {
  description = "Name of the SSM Parameter Store parameter for Discord bot token"
  type        = string
}

variable "discord_channel_id_parameter_name" {
  description = "Name of the SSM Parameter Store parameter for Discord channel ID"
  type        = string
}

variable "auto_shutdown_time" {
  description = "Time to automatically shut down the Minecraft server (cron expression in UTC)"
  type        = string
}