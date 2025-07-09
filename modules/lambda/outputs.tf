output "lambda_invoke_arns" {
  description = "A map of Lambda function invoke ARNs."
  value       = { for k, v in aws_lambda_function.user_lambdas : k => v.invoke_arn }
}

output "lambda_function_names" {
  description = "A map of Lambda function names."
  value       = { for k, v in aws_lambda_function.user_lambdas : k => v.function_name }
}

output "lambda_exec_role_arn" {
  description = "The ARN of the shared Lambda execution role."
  value       = aws_iam_role.lambda_exec_role.arn
}