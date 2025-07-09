variable "prefix" {
  type        = string
  description = "Prefix for tagging resources"
  default     = "mani-iac-milestone"
}

variable "region" {
  type        = string
  description = "AWS region to deploy infrastructure"
  default     = "ap-south-1"
}