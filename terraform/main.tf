# S3 Buckets for Terraform State, Mods, and Backups
module "s3" {
  source = "./modules/s3"

  project_name                  = var.project_name
  environment                   = var.environment
  terraform_state_bucket_name   = var.terraform_state_bucket_name
  terraform_state_lock_table_name = var.terraform_state_lock_table_name
  mods_bucket_name              = var.mods_bucket_name
  backup_bucket_name            = var.backup_bucket_name
}

# VPC and Network Configuration
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
}

# EFS for Minecraft Data
module "efs" {
  source = "./modules/efs"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
}

# ECS Cluster and Minecraft Server
module "ecs" {
  source = "./modules/ecs"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  minecraft_image  = var.minecraft_image
  minecraft_cpu    = var.minecraft_cpu
  minecraft_memory = var.minecraft_memory
  minecraft_port   = var.minecraft_port
  minecraft_env_vars = var.minecraft_env_vars
  efs_id           = module.efs.efs_id
  mods_bucket_name = module.s3.mods_bucket_name
}

# Lambda Functions for Discord Bot and Auto-shutdown
module "lambda" {
  source = "./modules/lambda"

  project_name                    = var.project_name
  environment                     = var.environment
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnet_ids
  ecs_cluster_name                = module.ecs.cluster_name
  ecs_service_name                = module.ecs.service_name
  discord_bot_token_parameter_name = var.discord_bot_token_parameter_name
  discord_channel_id_parameter_name = var.discord_channel_id_parameter_name
  auto_shutdown_time              = var.auto_shutdown_time
}

# API Gateway for Discord Bot
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name      = var.project_name
  environment       = var.environment
  lambda_function_name = module.lambda.discord_bot_function_name
  lambda_function_arn  = module.lambda.discord_bot_function_arn
}

# IAM Roles and Policies
module "iam" {
  source = "./modules/iam"

  project_name      = var.project_name
  environment       = var.environment
  mods_bucket_name  = module.s3.mods_bucket_name
  backup_bucket_name = module.s3.backup_bucket_name
}

# CloudWatch for Monitoring and Scheduling
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name      = var.project_name
  environment       = var.environment
  auto_shutdown_time = var.auto_shutdown_time
  lambda_function_arn = module.lambda.auto_shutdown_function_arn
}
