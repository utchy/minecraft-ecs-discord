variable "project_name" {
  description = "Name of the project, used as a prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "auto_shutdown_time" {
  description = "Time to automatically shut down the Minecraft server (cron expression in UTC)"
  type        = string
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to trigger for auto-shutdown"
  type        = string
}