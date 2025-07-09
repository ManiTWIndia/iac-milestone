# main.tf

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "mani-iac-milestone-tfstate"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name_prefix = var.user_prefix
  environment       = var.environment
}

module "s3_website" {
  source = "./modules/s3_website"

  bucket_name_prefix = var.user_prefix
  aws_region         = var.aws_region
  environment        = var.environment
}

module "lambda" {
  source = "./modules/lambda"

  prefix      = var.user_prefix
  environment = var.environment
  aws_region  = var.aws_region
  account_id  = data.aws_caller_identity.current.account_id

  enable_dynamodb_access = true
  dynamodb_table_arn     = module.dynamodb.table_arn

  enable_s3_access = true
  s3_bucket_arn    = module.s3_website.bucket_arn

  lambda_configs = {
    register_user = {
      source_dir = "register_user_lambda"
      env_vars = {
        DYNAMODB_TABLE_NAME = module.dynamodb.table_name
      }
    },
    verify_user = {
      source_dir = "verify_user_lambda"
      env_vars = {
        DYNAMODB_TABLE_NAME = module.dynamodb.table_name
        S3_BUCKET_NAME      = module.s3_website.bucket_id
      }
    }
  }
}

module "api_gateway" {
  source = "./modules/api_gateway"

  prefix      = var.user_prefix
  environment = var.environment

  integrations_config = {
    register_user_integration = {
      lambda_invoke_arn = module.lambda.lambda_invoke_arns["register_user"]
    },
    verify_user_integration = {
      lambda_invoke_arn = module.lambda.lambda_invoke_arns["verify_user"]
    }
  }

  routes_config = {
    register_user_route = {
      route_key       = "PUT /register"
      integration_key = "register_user_integration"
      lambda_name     = "register_user"
    },
    verify_user_route = {
      route_key       = "GET /verify"
      integration_key = "verify_user_integration"
      lambda_name     = "verify_user"
    }
  }

  lambda_function_names = module.lambda.lambda_function_names
}