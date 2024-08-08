resource "aws_api_gateway_rest_api" "api" {
  name        = "my-api"
  description = "My API Gateway"
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
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arns["welcomeLambda"]}/invocations"
}

resource "aws_api_gateway_integration" "greet_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.greet.id
  http_method             = aws_api_gateway_method.greet_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arns["greetingLambda"]}/invocations"
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