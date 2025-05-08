variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Name of the project, used as a prefix for resource names"
  type        = string
  default     = "minecraft-ecs-discord"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# ECS Configuration
variable "minecraft_image" {
  description = "Docker image for Minecraft server"
  type        = string
  default     = "itzg/minecraft-server:latest"
}

variable "minecraft_cpu" {
  description = "CPU units for Minecraft server task"
  type        = number
  default     = 1024
}

variable "minecraft_memory" {
  description = "Memory for Minecraft server task (MB)"
  type        = number
  default     = 2048
}

variable "minecraft_port" {
  description = "Port for Minecraft server"
  type        = number
  default     = 25565
}

variable "minecraft_env_vars" {
  description = "Environment variables for Minecraft server"
  type        = map(string)
  default = {
    EULA                    = "TRUE"
    TYPE                    = "PAPER"
    MEMORY                  = "1G"
    DIFFICULTY              = "normal"
    ALLOW_NETHER            = "true"
    ANNOUNCE_PLAYER_ACHIEVEMENTS = "true"
    ENABLE_COMMAND_BLOCK    = "true"
    GENERATE_STRUCTURES     = "true"
    LEVEL_TYPE              = "DEFAULT"
    MAX_PLAYERS             = "10"
    MODE                    = "survival"
    MOTD                    = "Weekend Minecraft Server"
    PVP                     = "true"
    ONLINE_MODE             = "true"
    VIEW_DISTANCE           = "10"
    SPAWN_PROTECTION        = "0"
  }
}

# S3 Configuration
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
  default     = "minecraft-ecs-discord-mods"
}

variable "backup_bucket_name" {
  description = "Name of the S3 bucket for storing Minecraft world backups"
  type        = string
  default     = "minecraft-ecs-discord-backups"
}

# Discord Bot Configuration
variable "discord_bot_token_parameter_name" {
  description = "Name of the SSM Parameter Store parameter for Discord bot token"
  type        = string
  default     = "/minecraft-ecs-discord/discord-bot-token"
}

variable "discord_channel_id_parameter_name" {
  description = "Name of the SSM Parameter Store parameter for Discord channel ID"
  type        = string
  default     = "/minecraft-ecs-discord/discord-channel-id"
}

# Auto-shutdown Configuration
variable "auto_shutdown_time" {
  description = "Time to automatically shut down the Minecraft server (cron expression in UTC)"
  type        = string
  default     = "cron(0 11 * * ? *)" # 20:00 JST = 11:00 UTC
}
