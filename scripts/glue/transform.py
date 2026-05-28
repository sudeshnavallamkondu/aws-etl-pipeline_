import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, explode
from datetime import datetime

# ── 1. INITIALIZE GLUE ──────────────────────────
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'RAW_BUCKET',
    'PROCESSED_BUCKET',
    'DATABASE_NAME'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

print("Glue job started!")

# ── 2. EXTRACT ───────────────────────────────────
# Read raw JSON files from S3
raw_path = f"s3://{args['RAW_BUCKET']}/raw/"
print(f"Reading from: {raw_path}")

df = spark.read.option("multiline", "true").json(raw_path)
print(f"Total records found: {df.count()}")
df.printSchema()

# ── 3. TRANSFORM ─────────────────────────────────
# Flatten the nested JSON structure
transformed_df = df.select(
    col("latitude").cast("double"),
    col("longitude").cast("double"),
    col("elevation").cast("double"),
    col("timezone"),
    col("current_weather.temperature").alias("temperature"),
    col("current_weather.windspeed").alias("windspeed"),
    col("current_weather.winddirection").alias("winddirection"),
    col("current_weather.weathercode").alias("weathercode"),
    col("current_weather.is_day").alias("is_day"),
    col("current_weather.time").alias("weather_time"),
    col("extracted_at")
)

print("Transformed schema:")
transformed_df.printSchema()
print(f"Transformed records: {transformed_df.count()}")

# ── 4. LOAD ──────────────────────────────────────
# Write clean data as Parquet to processed bucket
processed_path = f"s3://{args['PROCESSED_BUCKET']}/weather/"
print(f"Writing to: {processed_path}")

transformed_df.write \
    .mode("append") \
    .parquet(processed_path)

print("Glue job completed successfully!")
job.commit()