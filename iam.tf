# ─────────────────────────────────────────
# LAMBDA IAM ROLE
# ─────────────────────────────────────────

# This role is assumed by Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "etl-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "etl-pipeline"
  }
}

# Allow Lambda to write to S3 raw bucket + CloudWatch logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "etl-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow Lambda to write raw JSON to S3
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw_bucket.arn,
          "${aws_s3_bucket.raw_bucket.arn}/*"
        ]
      },
      {
        # Allow Lambda to write logs to CloudWatch
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ─────────────────────────────────────────
# GLUE IAM ROLE
# ─────────────────────────────────────────

# This role is assumed by Glue job
resource "aws_iam_role" "glue_role" {
  name = "etl-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "etl-pipeline"
  }
}

# Allow Glue to access S3 buckets + CloudWatch logs
resource "aws_iam_role_policy" "glue_policy" {
  name = "etl-glue-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow Glue to read raw JSON from raw bucket
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw_bucket.arn,
          "${aws_s3_bucket.raw_bucket.arn}/*"
        ]
      },
      {
        # Allow Glue to write Parquet to processed bucket
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.processed_bucket.arn,
          "${aws_s3_bucket.processed_bucket.arn}/*"
        ]
      },
      {
        # Allow Glue to read script from scripts bucket
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.scripts_bucket.arn,
          "${aws_s3_bucket.scripts_bucket.arn}/*"
        ]
      },
      {
        # Allow Glue to write logs to CloudWatch
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        # Allow Glue to access Glue catalog
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed Glue policy
resource "aws_iam_role_policy_attachment" "glue_managed_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}