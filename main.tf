provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# Create the secret in Secrets Manager
resource "aws_secretsmanager_secret" "api_key" {
  name        = var.api_key_secret_name
  description = "API key for API Gateway"
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "welcome_lambda" {
  function_name    = "welcomeLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "welcome_lambda.lambda_handler"
  runtime          = "python3.8"
  filename         = "lambda/welcome_lambda.zip"
  source_code_hash = filebase64sha256("lambda/welcome_lambda.zip")
}

resource "aws_lambda_function" "greeting_lambda" {
  function_name    = "greetingLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "greeting_lambda.lambda_handler"
  runtime          = "python3.8"
  filename         = "lambda/greeting_lambda.zip"
  source_code_hash = filebase64sha256("lambda/greeting_lambda.zip")
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "my-api"
  description = "My API"
}

resource "aws_api_gateway_resource" "welcome" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "welcome"
}

resource "aws_api_gateway_resource" "greet" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "greet"
}

resource "aws_api_gateway_method" "welcome_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.welcome.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "greet_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.greet.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "welcome_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.welcome.id
  http_method             = aws_api_gateway_method.welcome_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.welcome_lambda.arn}/invocations"
}

resource "aws_api_gateway_integration" "greet_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.greet.id
  http_method             = aws_api_gateway_method.greet_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.greeting_lambda.arn}/invocations"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.welcome_integration, aws_api_gateway_integration.greet_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name        = "my-usage-plan"
  description = "Usage plan for my API"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.api_deployment.stage_name
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name        = "my-api-key"
  description = "API key for accessing the API"
  enabled     = true
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

resource "aws_lambda_permission" "api_gateway_welcome" {
  statement_id  = "AllowAPIGatewayInvokeWelcome"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.welcome_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*/welcome"
}

resource "aws_lambda_permission" "api_gateway_greet" {
  statement_id  = "AllowAPIGatewayInvokeGreet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeting_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*/greet"
}
