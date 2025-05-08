# CloudWatch Event Rule for Auto-shutdown
resource "aws_cloudwatch_event_rule" "auto_shutdown" {
  name                = "${var.project_name}-auto-shutdown"
  description         = "Trigger auto-shutdown Lambda function at 20:00 JST"
  schedule_expression = var.auto_shutdown_time

  tags = {
    Name = "${var.project_name}-auto-shutdown"
  }
}

# CloudWatch Event Target for Auto-shutdown
resource "aws_cloudwatch_event_target" "auto_shutdown" {
  rule      = aws_cloudwatch_event_rule.auto_shutdown.name
  target_id = "auto_shutdown"
  arn       = var.lambda_function_arn
}

# CloudWatch Dashboard for Minecraft Server
resource "aws_cloudwatch_dashboard" "minecraft" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.project_name, { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "CPU Utilization"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", var.project_name, { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Memory Utilization"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          query   = "SOURCE '/aws/ecs/${var.project_name}' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region  = data.aws_region.current.name
          title   = "Minecraft Server Logs"
          view    = "table"
        }
      }
    ]
  })
}

# CloudWatch Alarm for High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = []
  dimensions = {
    ServiceName = var.project_name
  }

  tags = {
    Name = "${var.project_name}-high-cpu"
  }
}

# CloudWatch Alarm for High Memory Utilization
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ECS memory utilization"
  alarm_actions       = []
  dimensions = {
    ServiceName = var.project_name
  }

  tags = {
    Name = "${var.project_name}-high-memory"
  }
}

# Data sources
data "aws_region" "current" {}