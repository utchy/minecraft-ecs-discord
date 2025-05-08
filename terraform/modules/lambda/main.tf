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

# IAM Role for Lambda functions - Only created if not provided via variable
resource "aws_iam_role" "lambda" {
  count = var.lambda_role_arn == null ? 1 : 0

  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-role"
  }
}

# IAM Policy for Lambda to access ECS, SSM, and CloudWatch - Only created if role is not provided
resource "aws_iam_policy" "lambda" {
  count = var.lambda_role_arn == null ? 1 : 0

  name        = "${var.project_name}-lambda-policy"
  description = "Policy for Lambda functions to access ECS, SSM, and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = [
          aws_cloudwatch_log_group.discord_bot.arn,
          "${aws_cloudwatch_log_group.discord_bot.arn}:*",
          aws_cloudwatch_log_group.auto_shutdown.arn,
          "${aws_cloudwatch_log_group.auto_shutdown.arn}:*"
        ]
      },
      {
        Action = [
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTasks",
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:UpdateService"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.discord_bot_token_parameter_name}",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.discord_channel_id_parameter_name}"
        ]
      },
      {
        Action = [
          "ec2:DescribeNetworkInterfaces"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count = var.lambda_role_arn == null ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.lambda[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count = var.lambda_role_arn == null ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

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
  role          = var.lambda_role_arn != null ? var.lambda_role_arn : aws_iam_role.lambda[0].arn
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
      AWS_REGION = data.aws_region.current.name
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
  role          = var.lambda_role_arn != null ? var.lambda_role_arn : aws_iam_role.lambda[0].arn
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
      AWS_REGION = data.aws_region.current.name
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
