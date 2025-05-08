output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = aws_apigatewayv2_api.discord_bot.id
}

output "api_gateway_arn" {
  description = "The ARN of the API Gateway"
  value       = aws_apigatewayv2_api.discord_bot.arn
}

output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = aws_apigatewayv2_stage.discord_bot.invoke_url
}

output "webhook_url" {
  description = "The webhook URL for Discord integration"
  value       = "${aws_apigatewayv2_stage.discord_bot.invoke_url}/webhook"
}