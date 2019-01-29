resource "aws_iam_role" "lambda_role" {
  name = "${var.name_prefix}_lambda_role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "lambda.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
   }
 ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.name_prefix}_lambda_role"

  policy = <<EOF
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
                "arn:aws:s3:::${var.db_logs_state_bucket_name}",
                "arn:aws:logs:eu-west-1:*:*",
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

resource "aws_iam_role_policy_attachment" "attach" {
  role       = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../source/main.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "db_log_cloudwatch_forwarder" {
  filename      = "${path.module}/lambda_function.zip"
  function_name = "${var.lambda_name}"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "${var.lambda_handler}"
  runtime       = "${var.lamda_runtime}"
  timeout       = "${var.lambda_timeout_seconds}"
  memory_size   = "${var.lambda_memory_size}"

  environment {
    variables = {
      BUCKET_NAME             = "${var.db_logs_state_bucket_name}"
      DB_INSTANCE_IDENTIFIERS = "${var.DB_INSTANCE_IDENTIFIERS}"
      LOG_GROUP               = "${var.log_group_name}"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.db_log_cloudwatch_forwarder.function_name}"
  principal     = "logs.amazonaws.com"
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.db_logs_state_bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_cloudwatch_event_rule" "scheduled_rule" {
  name                = "scheduled_lambda_rule"
  description         = "every 12 hours"
  schedule_expression = "rate(12 hours)"
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = "${aws_cloudwatch_event_rule.scheduled_rule.name}"
  target_id = "db_log_cloudwatch_forwarder"
  arn       = "${aws_lambda_function.db_log_cloudwatch_forwarder.arn}"
}
