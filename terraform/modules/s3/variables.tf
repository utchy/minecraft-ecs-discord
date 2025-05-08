variable "project_name" {
  description = "Name of the project, used as a prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  type        = string
  default     = "minecraft-ecs-discord-tfstate"
}

variable "terraform_state_lock_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "minecraft-ecs-discord-tfstate-lock"
}

variable "mods_bucket_name" {
  description = "Name of the S3 bucket for storing Minecraft mods"
  type        = string
}

variable "backup_bucket_name" {
  description = "Name of the S3 bucket for storing Minecraft world backups"
  type        = string
}