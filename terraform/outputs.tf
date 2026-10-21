output "function_name" {
  description = "Function name to use with aws lambda invoke."
  value       = aws_lambda_function.dummy.function_name
}

output "function_arn" {
  description = "Exact function ARN for the GitHub role's invocation policy in step 3."
  value       = aws_lambda_function.dummy.arn
}
