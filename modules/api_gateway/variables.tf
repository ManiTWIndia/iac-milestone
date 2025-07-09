variable "prefix" {
  description = "A unique prefix for naming API Gateway resources."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "integrations_config" {
  description = "A map describing API Gateway integrations."
  type = map(object({
    lambda_invoke_arn = string
  }))
}

variable "routes_config" {
  description = "A map describing API Gateway routes."
  type = map(object({
    route_key       = string
    integration_key = string 
    lambda_name     = string 
  }))
}

variable "lambda_function_names" {
  description = "A map of Lambda function names, keyed by their logical name (e.g., 'register_user')."
  type        = map(string)
}