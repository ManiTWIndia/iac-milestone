variable "prefix" {
  description = "A unique prefix for naming Lambda resources."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
}

variable "account_id" {
  description = "The AWS account ID."
  type        = string
}

variable "lambda_configs" {
  description = "A map of Lambda function configurations."
  type = map(object({
    source_dir = string # Relative path from src/ to the lambda code directory (e.g., "register_user_lambda")
    env_vars   = map(string)
  }))
}

variable "runtime" {
  description = "The runtime for the Lambda functions."
  type        = string
  default     = "python3.9"
}

variable "timeout" {
  description = "The timeout for the Lambda functions in seconds."
  type        = number
  default     = 30
}

variable "enable_dynamodb_access" {
  description = "Whether to attach DynamoDB access policy to Lambda role."
  type        = bool
  default     = false
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table if DynamoDB access is enabled."
  type        = string
  default     = null
}

variable "enable_s3_access" {
  description = "Whether to attach S3 access policy to Lambda role."
  type        = bool
  default     = false
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket if S3 access is enabled."
  type        = string
  default     = null
}