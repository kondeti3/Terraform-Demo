resource "aws_api_gateway_rest_api" "api" {
  name        = "my-api"
  description = "My API Gateway"
}

resource "aws_api_gateway_resource" "resource" {
  for_each   = {
    welcome = "welcome1"
    greeting   = "greeting"
  }
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value
}

resource "aws_api_gateway_method" "method" {
  for_each     = {
    welcome_get = {
      resource = aws_api_gateway_resource.resource["welcome"].id
      method   = "GET"
    }
    greeting_post = {
      resource = aws_api_gateway_resource.resource["greeting"].id
      method   = "POST"
    }
  }
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = each.value.resource
  http_method   = each.value.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  for_each = {
    welcome_integration = {
      resource_id = aws_api_gateway_resource.resource["welcome"].id
      http_method = aws_api_gateway_method.method["welcome_get"].http_method
      lambda_arn  = "welcomeLambda"
    }
    greet_integration = {
      resource_id = aws_api_gateway_resource.resource["greeting"].id
      http_method = aws_api_gateway_method.method["greeting_post"].http_method
      lambda_arn  = "greetingLambda"
    }
  }
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = each.value.resource_id
  http_method             = each.value.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arns[each.value.lambda_arn]}/invocations"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.integration]
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
