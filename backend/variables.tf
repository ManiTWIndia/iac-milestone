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

variable "repo_name" {
  description = "The GitHub repository in the format OWNER/REPOSITORY"
  type        = string
  default     = "ManiTWIndia/iac-milestone"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}