# ─────────────────────────────────────────
# GLUE DATABASE
# ─────────────────────────────────────────
resource "aws_glue_catalog_database" "etl_database" {
  name = "etl_weather_database"
}

# ─────────────────────────────────────────
# UPLOAD GLUE SCRIPT TO S3
# ─────────────────────────────────────────
resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.scripts_bucket.bucket
  key    = "scripts/transform.py"
  source = "${path.module}/scripts/glue/transform.py"
  etag   = filemd5("${path.module}/scripts/glue/transform.py")
}

# ─────────────────────────────────────────
# GLUE JOB
# ─────────────────────────────────────────
resource "aws_glue_job" "transform" {
  name         = "etl-transform-weather"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"
  worker_type  = "G.1X"
  number_of_workers = 2
  timeout      = 10

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.scripts_bucket.bucket}/scripts/transform.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--RAW_BUCKET"          = aws_s3_bucket.raw_bucket.bucket
    "--PROCESSED_BUCKET"    = aws_s3_bucket.processed_bucket.bucket
    "--DATABASE_NAME"       = aws_glue_catalog_database.etl_database.name
    "--enable-continuous-cloudwatch-log" = "true"
  }

  tags = {
    Name    = "ETL Transform Weather"
    Project = "etl-pipeline"
  }
}

# ─────────────────────────────────────────
# GLUE CRAWLER
# ─────────────────────────────────────────
resource "aws_glue_crawler" "weather_crawler" {
  name          = "etl-weather-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.etl_database.name

  s3_target {
    path = "s3://${aws_s3_bucket.processed_bucket.bucket}/weather/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  tags = {
    Name    = "ETL Weather Crawler"
    Project = "etl-pipeline"
  }
}