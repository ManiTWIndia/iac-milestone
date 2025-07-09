resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.prefix}-lambda-exec-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "${var.prefix}-lambda-cloudwatch-policy-${var.environment}"
  description = "IAM policy for Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/lambda/*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  count       = var.enable_dynamodb_access ? 1 : 0
  name        = "${var.prefix}-lambda-dynamodb-policy-${var.environment}"
  description = "IAM policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Effect = "Allow",
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  count      = var.enable_dynamodb_access ? 1 : 0
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy[0].arn
}

resource "aws_iam_policy" "lambda_s3_policy" {
  count       = var.enable_s3_access ? 1 : 0
  name        = "${var.prefix}-lambda-s3-policy-${var.environment}"
  description = "IAM policy for Lambda to read from S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ],
        Effect = "Allow",
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attachment" {
  count      = var.enable_s3_access ? 1 : 0
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy[0].arn
}

resource "aws_lambda_function" "user_lambdas" {
  for_each = var.lambda_configs

  function_name = "${var.prefix}-${each.key}-${var.environment}"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler" # All use lambda_function.py inside their dir
  runtime       = var.runtime
  timeout       = var.timeout

  filename         = data.archive_file.lambda_zips[each.key].output_path
  source_code_hash = data.archive_file.lambda_zips[each.key].output_base64sha256

  environment {
    variables = each.value.env_vars
  }

  tags = {
    Name        = "${var.prefix}-${each.key}-${var.environment}"
    Environment = var.environment
  }
}

data "archive_file" "lambda_zips" {
  for_each = var.lambda_configs

  type        = "zip"
  source_dir  = "${path.module}/../../src/${each.value.source_dir}"
  output_path = "${path.module}/../../dist/${each.key}_lambda.zip"
}