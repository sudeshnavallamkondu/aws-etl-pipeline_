import json
import urllib.request
import boto3
from datetime import datetime
import os

def lambda_handler(event, context):
    
    # ── 1. EXTRACT ──────────────────────────────
    # Call Open Meteo weather API (New York coordinates)
    url = (
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=40.71"
        "&longitude=-74.01"
        "&current_weather=true"
    )
    
    with urllib.request.urlopen(url) as response:
        raw_data = json.loads(response.read().decode())
    
    print(f"Extracted weather data: {raw_data}")
    
    # ── 2. ADD TIMESTAMP ─────────────────────────
    raw_data["extracted_at"] = datetime.utcnow().isoformat()
    
    # ── 3. LOAD TO S3 ────────────────────────────
    s3 = boto3.client("s3")
    
    # Create unique filename using timestamp
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    file_name = f"weather_raw_{timestamp}.json"
    
    # Get bucket name from environment variable
    bucket_name = os.environ["RAW_BUCKET_NAME"]
    
    # Upload to S3
    s3.put_object(
        Bucket=bucket_name,
        Key=f"raw/{file_name}",
        Body=json.dumps(raw_data),
        ContentType="application/json"
    )
    
    print(f"Saved to S3: s3://{bucket_name}/raw/{file_name}")
    
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Weather data extracted and saved!",
            "file": file_name
        })
    }