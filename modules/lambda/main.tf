resource "aws_lambda_function" "welcome_lambda" {
  function_name    = "welcomeLambda"
  role             = var.lambda_role_arn
  handler          = "welcome_lambda.lambda_handler"
  runtime          = "python3.8"
  filename         = "modules/lambda/welcome_lambda.zip"
  source_code_hash = filebase64sha256("modules/lambda/welcome_lambda.zip")
}

resource "aws_lambda_function" "greeting_lambda" {
  function_name    = "greetingLambda"
  role             = var.lambda_role_arn
  handler          = "greeting_lambda.lambda_handler"
  runtime          = "python3.8"
  filename         = "modules/lambda/greeting_lambda.zip"
  source_code_hash = filebase64sha256("modules/lambda/greeting_lambda.zip")
}

resource "aws_lambda_permission" "api_gateway_welcome" {
  statement_id  = "AllowAPIGatewayInvokeWelcome"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.welcome_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/*/welcome"
}

resource "aws_lambda_permission" "api_gateway_greet" {
  statement_id  = "AllowAPIGatewayInvokeGreet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeting_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/*/greet"
}

data "aws_caller_identity" "current" {}
