output "invoke_url" {
  description = "The URL to invoke the API Gateway."
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}