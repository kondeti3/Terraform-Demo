variable "lambda_role_arn" {
  description = "The ARN of the Lambda execution role"
  type        = string
}

variable "api_key_secret_name" {
  description = "The name of the secret in AWS Secrets Manager for the API key"
  type        = string
}

variable "api_key" {
  description = "The API key value"
  type        = string
}

variable "api_gateway_id" {
  description = "ID of the API Gateway"
  type        = string
}

variable "region" {
  description = "The AWS region where resources are deployed"
  type        = string
}