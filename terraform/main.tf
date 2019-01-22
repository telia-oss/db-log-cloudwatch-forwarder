resource "aws_iam_role" "lambda_role" {
  name = "${var.name_prefix}_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:CreateLogGroup",
                "logs:DescribeLogStreams",
                "rds:DownloadDBLogFilePortion",
                "s3:ListBucket",
                "rds:DescribeDBLogFiles",
                "logs:PutLogEvents",
                "s3:PutBucketVersioning"
            ],
            "Resource": [
                "arn:aws:s3:::db-logs-state-stage",
                "arn:aws:logs:eu-west-1:*:*",
                "arn:aws:logs:eu-west-1:*:log-group:rds_logs:log-stream:*",
                "arn:aws:rds:eu-west-1:*:db:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::${var.db_logs_state_bucket_name}/*"
        }
    ]
}
EOF
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "https://github.com/telia-oss/db-log-cloudwatch-forwarder/source/main.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "db_log_cloudwatch_forwarder" {
  function_name = "${var.lambda_name}"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "${var.lambda_handler}"
  runtime       = "${var.lamda_runtime}"
  timeout       = "${var.lambda_timeout_seconds}"
  memory_size   = "${var.lambda_memory_size}"

  environment {
    variables = {
      bucket_name             = "${var.db_logs_state_bucket_name}"
      DB_INSTANCE_IDENTIFIERS = "${var.DB_INSTANCE_IDENTIFIERS}"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.db_log_cloudwatch_forwarder.function_name}"
  principal     = "logs.amazonaws.com"
}
