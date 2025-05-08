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
  description = "The IDs of the subnets where ECS tasks will run"
  type        = list(string)
}

variable "minecraft_image" {
  description = "Docker image for Minecraft server"
  type        = string
}

variable "minecraft_cpu" {
  description = "CPU units for Minecraft server task"
  type        = number
}

variable "minecraft_memory" {
  description = "Memory for Minecraft server task (MB)"
  type        = number
}

variable "minecraft_port" {
  description = "Port for Minecraft server"
  type        = number
}

variable "minecraft_env_vars" {
  description = "Environment variables for Minecraft server"
  type        = map(string)
}

variable "efs_id" {
  description = "The ID of the EFS file system"
  type        = string
}

variable "minecraft_access_point_id" {
  description = "The ID of the Minecraft access point"
  type        = string
  default     = null
}

variable "mods_access_point_id" {
  description = "The ID of the mods access point"
  type        = string
  default     = null
}

variable "backups_access_point_id" {
  description = "The ID of the backups access point"
  type        = string
  default     = null
}

variable "mods_bucket_name" {
  description = "Name of the S3 bucket for storing Minecraft mods"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task IAM role"
  type        = string
}
