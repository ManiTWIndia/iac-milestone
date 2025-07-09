variable "table_name_prefix" {
  description = "A unique prefix for the DynamoDB table name."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}