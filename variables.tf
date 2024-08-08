variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "api_key_secret_name" {
  description = "The name of the AWS Secrets Manager secret containing the API key"
  type        = string
}

variable "api_key" {
  description = "The API key to store in Secrets Manager"
  type        = string
}
