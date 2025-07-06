output "api_gateway_invoke_url" {
  description = "The URL to invoke the API Gateway."
  value       = aws_apigatewayv2_stage.default.invoke_url
}