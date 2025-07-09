# outputs.tf

output "api_gateway_invoke_url" {
  description = "The URL to invoke the API Gateway."
  value       = module.api_gateway.invoke_url
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB users table."
  value       = module.dynamodb.table_name
}

output "s3_website_bucket_id" {
  description = "ID of the S3 bucket hosting the static website."
  value       = module.s3_website.bucket_id
}

output "s3_website_bucket_arn" {
  description = "ARN of the S3 bucket hosting the static website."
  value       = module.s3_website.bucket_arn
}

output "register_user_lambda_name" {
  description = "Name of the register_user Lambda function."
  value       = module.lambda.lambda_function_names["register_user"]
}

output "verify_user_lambda_name" {
  description = "Name of the verify_user Lambda function."
  value       = module.lambda.lambda_function_names["verify_user"]
}

output "lambda_invoke_arns" {
  value = module.lambda.lambda_invoke_arns
}