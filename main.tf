terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "archive_file" "hello_world_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/hello_world"
  output_path = "${path.module}/hello_world.zip"
}

resource "aws_cloudwatch_log_group" "hello_world_lambda_logs" {
  name              = "/aws/lambda/${var.user_prefix}-hello-world"
  retention_in_days = 7 # Automatically delete old logs
}

resource "aws_iam_role" "hello_world_lambda_role" {
  name = "${var.user_prefix}-hello-world-lambda-role"

  # Policy that allows this role to be assumed by the Lambda service.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "${var.user_prefix}-lambda-logging-policy"
  description = "IAM policy for logging from the hello-world lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        # Important: Restrict this permission to our specific log group.
        Resource = "${aws_cloudwatch_log_group.hello_world_lambda_logs.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  role       = aws_iam_role.hello_world_lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

resource "aws_lambda_function" "hello_world_lambda" {
  function_name = "${var.user_prefix}-hello-world"
  role          = aws_iam_role.hello_world_lambda_role.arn

  filename         = data.archive_file.hello_world_zip.output_path
  handler          = "lambda_function.lambda_handler" # filename.function_name
  runtime          = "python3.9"
  source_code_hash = data.archive_file.hello_world_zip.output_base64sha256
}

resource "aws_apigatewayv2_api" "main_api" {
  name          = "${var.user_prefix}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.main_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello_world_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_root" {
  api_id    = aws_apigatewayv2_api.main_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_deployment" "main_deployment" {
  api_id = aws_apigatewayv2_api.main_api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.get_root,
  ]
}

resource "aws_apigatewayv2_stage" "default" {
  api_id        = aws_apigatewayv2_api.main_api.id
  name          = "$default"
  deployment_id = aws_apigatewayv2_deployment.main_deployment.id
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main_api.execution_arn}/*/${aws_apigatewayv2_route.get_root.route_key}"
}