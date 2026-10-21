provider "aws" {
  region              = "eu-north-1"
  allowed_account_ids = ["535337619181"]
}

locals {
  function_name = "lambda-oidc-invoke-dummy"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../lambda/index.mjs"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${local.function_name}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy" "lambda_logs" {
  name = "write-function-logs"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
    }]
  })
}

resource "aws_lambda_function" "dummy" {
  function_name    = local.function_name
  role             = aws_iam_role.lambda.arn
  runtime          = "nodejs24.x"
  handler          = "index.handler"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  memory_size      = 128
  timeout          = 3

  depends_on = [aws_iam_role_policy.lambda_logs]
}
