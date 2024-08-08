variable "api_key_secret_name" {
  description = "Name of the secret for the API key"
  type        = string
}

variable "api_key" {
  description = "The API key to store in Secrets Manager"
  type        = string
}
