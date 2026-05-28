# Zip the extract.py script
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/scripts/lambda/extract.py"
  output_path = "${path.module}/scripts/lambda/extract.zip"
}

# Create Lambda function
resource "aws_lambda_function" "extract" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "etl-extract-weather"
  role             = aws_iam_role.lambda_role.arn
  handler          = "extract.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Pass bucket name as environment variable
  environment {
    variables = {
      RAW_BUCKET_NAME = aws_s3_bucket.raw_bucket.bucket
    }
  }

  tags = {
    Name    = "ETL Extract Lambda"
    Project = "etl-pipeline"
  }
}

# CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/etl-extract-weather"
  retention_in_days = 7

  tags = {
    Project = "etl-pipeline"
  }
}