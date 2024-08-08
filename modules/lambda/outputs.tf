output "welcome_lambda_arn" {
  value = aws_lambda_function.welcome_lambda.arn
}

output "greeting_lambda_arn" {
  value = aws_lambda_function.greeting_lambda.arn
}