# AWS ETL Pipeline with Terraform

An end-to-end ETL pipeline on AWS provisioned entirely with Terraform.
Extracts real-time weather data, transforms it using PySpark, and makes
it queryable with SQL.

## Architecture
Open Meteo API (Free Weather API)
↓
AWS Lambda (Extract)
↓
S3 Raw Bucket (raw JSON)
↓
AWS Glue Job (Transform - PySpark)
↓
S3 Processed Bucket (Parquet)
↓
Glue Crawler → Glue Data Catalog
↓
Amazon Athena (Query with SQL)

## AWS Services Used

| Service | Purpose |
|---|---|
| AWS Lambda | Extracts weather data from Open Meteo API |
| Amazon S3 | Stores raw JSON and transformed Parquet files |
| AWS Glue Job | Transforms nested JSON to flat Parquet using PySpark |
| AWS Glue Crawler | Scans processed data and creates table schema |
| AWS Glue Catalog | Stores table metadata for Athena |
| Amazon Athena | Queries processed data with SQL |
| AWS IAM | Manages roles and permissions |
| CloudWatch | Monitors Lambda and Glue logs |

## Project Structure
aws-etl-pipeline/
├── main.tf              # Provider configuration
├── s3.tf                # S3 buckets
├── iam.tf               # IAM roles and policies
├── lambda.tf            # Lambda function
├── glue.tf              # Glue job, crawler, database
├── scripts/
│   ├── lambda/
│   │   └── extract.py   # Lambda - calls weather API
│   └── glue/
│       └── transform.py # Glue - transforms JSON to Parquet
└── README.md


## Prerequisites

- AWS Account (free tier)
- Terraform installed
- AWS CLI installed and configured
- Python 3.12+



