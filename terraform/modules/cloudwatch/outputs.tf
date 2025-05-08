output "auto_shutdown_rule_arn" {
  description = "The ARN of the CloudWatch Event Rule for auto-shutdown"
  value       = aws_cloudwatch_event_rule.auto_shutdown.arn
}

output "auto_shutdown_rule_name" {
  description = "The name of the CloudWatch Event Rule for auto-shutdown"
  value       = aws_cloudwatch_event_rule.auto_shutdown.name
}

output "dashboard_name" {
  description = "The name of the CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.minecraft.dashboard_name
}

output "high_cpu_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for high CPU utilization"
  value       = aws_cloudwatch_metric_alarm.high_cpu.arn
}

output "high_memory_alarm_arn" {
  description = "The ARN of the CloudWatch Alarm for high memory utilization"
  value       = aws_cloudwatch_metric_alarm.high_memory.arn
}