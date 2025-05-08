# ECR Repository for Lambda container images
resource "aws_ecr_repository" "discord_bot" {
  name                 = "${var.project_name}-discord-bot"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-discord-bot"
  }
}

resource "aws_ecr_repository" "auto_shutdown" {
  name                 = "${var.project_name}-auto-shutdown"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-auto-shutdown"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "discord_bot" {
  name              = "/aws/lambda/${var.project_name}-discord-bot"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-discord-bot-logs"
  }
}

resource "aws_cloudwatch_log_group" "auto_shutdown" {
  name              = "/aws/lambda/${var.project_name}-auto-shutdown"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-auto-shutdown-logs"
  }
}

# Using IAM role from the IAM module

# Security Group for Lambda functions
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-lambda-sg"
  }
}

# Discord Bot Lambda Function
resource "aws_lambda_function" "discord_bot" {
  function_name = "${var.project_name}-discord-bot"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.discord_bot.repository_url}:latest"
  timeout       = 30
  memory_size   = 256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      ECS_CLUSTER_NAME = var.ecs_cluster_name
      ECS_SERVICE_NAME = var.ecs_service_name
      DISCORD_BOT_TOKEN_PARAMETER = var.discord_bot_token_parameter_name
      DISCORD_CHANNEL_ID_PARAMETER = var.discord_channel_id_parameter_name
      CURRENT_REGION = data.aws_region.current.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.discord_bot
  ]

  tags = {
    Name = "${var.project_name}-discord-bot"
  }
}

# Auto-shutdown Lambda Function
resource "aws_lambda_function" "auto_shutdown" {
  function_name = "${var.project_name}-auto-shutdown"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.auto_shutdown.repository_url}:latest"
  timeout       = 30
  memory_size   = 128

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      ECS_CLUSTER_NAME = var.ecs_cluster_name
      ECS_SERVICE_NAME = var.ecs_service_name
      DISCORD_BOT_TOKEN_PARAMETER = var.discord_bot_token_parameter_name
      DISCORD_CHANNEL_ID_PARAMETER = var.discord_channel_id_parameter_name
      CURRENT_REGION = data.aws_region.current.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.auto_shutdown
  ]

  tags = {
    Name = "${var.project_name}-auto-shutdown"
  }
}

# CloudWatch Event Rule for Auto-shutdown
resource "aws_cloudwatch_event_rule" "auto_shutdown" {
  name                = "${var.project_name}-auto-shutdown"
  description         = "Trigger auto-shutdown Lambda function at 20:00 JST"
  schedule_expression = var.auto_shutdown_time

  tags = {
    Name = "${var.project_name}-auto-shutdown"
  }
}

resource "aws_cloudwatch_event_target" "auto_shutdown" {
  rule      = aws_cloudwatch_event_rule.auto_shutdown.name
  target_id = "auto_shutdown"
  arn       = aws_lambda_function.auto_shutdown.arn
}

resource "aws_lambda_permission" "auto_shutdown" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_shutdown.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_shutdown.arn
}

# SSM Parameters for Discord Bot
resource "aws_ssm_parameter" "discord_bot_token" {
  name        = var.discord_bot_token_parameter_name
  description = "Discord Bot Token"
  type        = "SecureString"
  value       = "placeholder-replace-with-actual-token"  # This should be replaced with the actual token

  lifecycle {
    ignore_changes = [value]
  }

  tags = {
    Name = "${var.project_name}-discord-bot-token"
  }
}

resource "aws_ssm_parameter" "discord_channel_id" {
  name        = var.discord_channel_id_parameter_name
  description = "Discord Channel ID"
  type        = "String"
  value       = "placeholder-replace-with-actual-channel-id"  # This should be replaced with the actual channel ID

  lifecycle {
    ignore_changes = [value]
  }

  tags = {
    Name = "${var.project_name}-discord-channel-id"
  }
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
