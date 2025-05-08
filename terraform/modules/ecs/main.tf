# ECS Cluster
resource "aws_ecs_cluster" "minecraft" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "minecraft" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "minecraft" {
  name        = "${var.project_name}-minecraft-sg"
  description = "Allow Minecraft traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Minecraft server port"
    from_port   = var.minecraft_port
    to_port     = var.minecraft_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-minecraft-sg"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ecs-task-execution"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ecs-task"
  }
}

# IAM Policy for ECS Task to access S3 and EFS
resource "aws_iam_policy" "ecs_task" {
  name        = "${var.project_name}-ecs-task-policy"
  description = "Policy for ECS task to access S3 and EFS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.mods_bucket_name}",
          "arn:aws:s3:::${var.mods_bucket_name}/*"
        ]
      },
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

# ECS Task Definition
resource "aws_ecs_task_definition" "minecraft" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.minecraft_cpu
  memory                   = var.minecraft_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "minecraft"
      image     = var.minecraft_image
      essential = true
      
      portMappings = [
        {
          containerPort = var.minecraft_port
          hostPort      = var.minecraft_port
          protocol      = "tcp"
        }
      ]
      
      environment = [
        for key, value in var.minecraft_env_vars : {
          name  = key
          value = value
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "minecraft-data"
          containerPath = "/data"
          readOnly      = false
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.minecraft.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "minecraft"
        }
      }
    },
    {
      name      = "mod-sync"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.project_name}-mod-sync:latest"
      essential = false
      
      environment = [
        {
          name  = "S3_BUCKET"
          value = var.mods_bucket_name
        },
        {
          name  = "MODS_DIR"
          value = "/minecraft/mods"
        },
        {
          name  = "SYNC_INTERVAL"
          value = "300"  # 5 minutes
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "minecraft-mods"
          containerPath = "/minecraft/mods"
          readOnly      = false
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.minecraft.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "mod-sync"
        }
      }
    }
  ])

  volume {
    name = "minecraft-data"
    
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.minecraft_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "minecraft-mods"
    
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.mods_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  tags = {
    Name = "${var.project_name}-task"
  }
}

# ECS Service
resource "aws_ecs_service" "minecraft" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.minecraft.id
  task_definition = aws_ecs_task_definition.minecraft.arn
  desired_count   = 0  # Start with 0 instances, will be controlled by Discord bot
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.minecraft.id]
    assign_public_ip = true
  }

  tags = {
    Name = "${var.project_name}-service"
  }
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}