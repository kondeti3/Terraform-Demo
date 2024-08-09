resource "aws_lambda_function" "lambda_function" {
  for_each = {
    welcomeLambda   = "modules/lambda/welcome_lambda.zip"
    greetingLambda  = "modules/lambda/greeting_lambda.zip"
  }
  function_name    = "${each.key}-${terraform.workspace}"
  role             = var.lambda_role_arn
  handler          = "${each.key}.lambda_handler"
  runtime          = "python3.8"
  filename         = each.value
  source_code_hash = filebase64sha256(each.value)
}

resource "aws_lambda_permission" "lambda_permission" {
  for_each = {
    api_gateway_welcome = {
      lambda_function = aws_lambda_function.lambda_function["welcomeLambda"].function_name
      api_path        = "welcome"
    }
    api_gateway_greet = {
      lambda_function = aws_lambda_function.lambda_function["greetingLambda"].function_name
      api_path        = "greet"
    }
  }
  statement_id  = "AllowAPIGatewayInvoke${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/*/${each.value.api_path}"
}

data "aws_caller_identity" "current" {}

output "lambda_arns" {
  value = {
    for k, v in aws_lambda_function.lambda_function : k => v.arn
  }
}
