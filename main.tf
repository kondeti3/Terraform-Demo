provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

module "secretesmanager"{
  source = "./modules/secretesmanager"
  api_key_secret_name = var.api_key_secret_name
  api_key = var.api_key
}

module "iam" {
  source = "./modules/iam"
}

module "lambda" {
  source         = "./modules/lambda"
  api_gateway_id = module.api_gateway.api_id
  api_key = var.api_key
  api_key_secret_name = var.api_key_secret_name
  lambda_role_arn = module.iam.lambda_role_arn
  region         = var.region
}

module "api_gateway" {
  source      = "./modules/api_gateway"
  lambda_arns = {
    welcomeLambda = module.lambda.welcome_lambda_arn
    greetingLambda = module.lambda.greeting_lambda_arn
  }
  region       = var.region
}
