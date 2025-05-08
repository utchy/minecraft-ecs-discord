variable "project_name" {
  description = "Name of the project, used as a prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "mods_bucket_name" {
  description = "Name of the S3 bucket for storing Minecraft mods"
  type        = string
}

variable "backup_bucket_name" {
  description = "Name of the S3 bucket for storing Minecraft world backups"
  type        = string
}