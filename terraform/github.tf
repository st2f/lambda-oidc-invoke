data "aws_iam_role" "github_ci" {
  name = "github-ci-role"
}

resource "aws_iam_role_policy" "github_invoke_lambda" {
  name = "invoke-${local.function_name}"
  role = data.aws_iam_role.github_ci.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = aws_lambda_function.dummy.arn
    }]
  })
}
