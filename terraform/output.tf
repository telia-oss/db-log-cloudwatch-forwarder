output "aws_lambda_arn" {
  description = "The ARN of the lambda function that forwards db logs to the cloudwatch "
  value       = "${aws_lambda_function.db_log_cloudwatch_forwarder.arn}"
}
