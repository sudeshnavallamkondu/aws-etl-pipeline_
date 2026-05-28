# Random suffix to make bucket names globally unique
resource "random_id" "suffix" {
  byte_length = 4
}

# Raw bucket - Lambda drops raw JSON here
resource "aws_s3_bucket" "raw_bucket" {
  bucket        = "etl-raw-bucket-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name    = "ETL Raw Bucket"
    Project = "etl-pipeline"
  }
}

# Processed bucket - Glue writes clean Parquet here
resource "aws_s3_bucket" "processed_bucket" {
  bucket        = "etl-processed-bucket-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name    = "ETL Processed Bucket"
    Project = "etl-pipeline"
  }
}

# Scripts bucket - Glue job Python script lives here
resource "aws_s3_bucket" "scripts_bucket" {
  bucket        = "etl-scripts-bucket-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name    = "ETL Scripts Bucket"
    Project = "etl-pipeline"
  }
}

# Athena results bucket - Athena query output goes here
resource "aws_s3_bucket" "athena_bucket" {
  bucket        = "etl-athena-results-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name    = "ETL Athena Results Bucket"
    Project = "etl-pipeline"
  }
}