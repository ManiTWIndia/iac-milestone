resource "aws_apigatewayv2_api" "main_api" {
  name          = "${var.prefix}-api-${var.environment}"
  protocol_type = "HTTP"

  tags = {
    Name        = "${var.prefix}-api-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each = var.integrations_config

  api_id                 = aws_apigatewayv2_api.main_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_routes" {
  for_each = var.routes_config

  api_id    = aws_apigatewayv2_api.main_api.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integrations[each.value.integration_key].id}"
}

resource "aws_apigatewayv2_deployment" "main_deployment" {
  api_id = aws_apigatewayv2_api.main_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_apigatewayv2_route.api_routes,
      aws_apigatewayv2_integration.lambda_integrations,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.main_api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name        = "${var.prefix}-api-default-stage-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "api_gateway_permissions" {
  for_each = var.routes_config

  statement_id  = "AllowAPIGatewayInvoke${replace(each.key, "-", "")}" # Unique ID
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names[each.value.lambda_name]
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.main_api.execution_arn}/*/*"
}