# API Gateway for Discord Bot
resource "aws_apigatewayv2_api" "discord_bot" {
  name          = "${var.project_name}-discord-bot"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token"]
  }

  tags = {
    Name = "${var.project_name}-discord-bot"
  }
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "discord_bot" {
  api_id      = aws_apigatewayv2_api.discord_bot.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Name = "${var.project_name}-discord-bot-stage"
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-discord-bot"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-api-gateway-logs"
  }
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "discord_bot" {
  api_id                 = aws_apigatewayv2_api.discord_bot.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_function_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Gateway Route
resource "aws_apigatewayv2_route" "discord_bot" {
  api_id    = aws_apigatewayv2_api.discord_bot.id
  route_key = "POST /webhook"
  target    = "integrations/${aws_apigatewayv2_integration.discord_bot.id}"
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.discord_bot.execution_arn}/*/*/webhook"
}