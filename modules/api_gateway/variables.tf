variable "region" {
  description = "The AWS region where resources are deployed"
  type        = string
}

variable "lambda_arns" {
  description = "Map of Lambda function ARNs"
  type        = map(string)
}
