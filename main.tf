provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

module "secretesmanager" {
  source              = "./modules/secretesmanager"
  api_key_secret_name = var.api_key_secret_name
  api_key             = var.api_key
}

module "iam" {
  source = "./modules/iam"
}

module "lambda" {
  source         = "./modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn
  region         = var.region
  api_gateway_id = module.api_gateway.api_id
  api_key = var.api_key
  api_key_secret_name = var.api_key_secret_name
}

module "api_gateway" {
  source      = "./modules/api_gateway"
  lambda_arns = module.lambda.lambda_arns
  region      = var.region
}
