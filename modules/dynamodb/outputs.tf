output "table_name" {
  description = "The name of the DynamoDB users table."
  value       = aws_dynamodb_table.users_table.name
}

output "table_arn" {
  description = "The ARN of the DynamoDB users table."
  value       = aws_dynamodb_table.users_table.arn
}