import json
import boto3
import csv
import io
import os
from datetime import datetime

s3 = boto3.client("s3")

DEST_BUCKET = os.environ.get("DEST_BUCKET")

def lambda_handler(event, context):
    try:
        # Get bucket and file details from S3 event
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        source_key = event['Records'][0]['s3']['object']['key']

        print(f"Processing file: {source_key} from bucket: {source_bucket}")

        # Get file from S3
        response = s3.get_object(Bucket=source_bucket, Key=source_key)
        content = response['Body'].read().decode('utf-8')

        # Read CSV
        csv_file = io.StringIO(content)
        reader = csv.DictReader(csv_file)

        total_records = 0
        total_amount = 0.0

        for row in reader:
            total_records += 1
            if 'amount' in row and row['amount']:
                total_amount += float(row['amount'])

        average_amount = total_amount / total_records if total_records > 0 else 0

        # Create summary
        summary = {
            "source_file": source_key,
            "processed_at": datetime.utcnow().isoformat(),
            "total_records": total_records,
            "total_amount": total_amount,
            "average_amount": average_amount
        }

        summary_content = json.dumps(summary, indent=4)

        # Define output file name
        output_key = f"processed/summary-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.json"

        # Upload summary to destination bucket
        s3.put_object(
            Bucket=DEST_BUCKET,
            Key=output_key,
            Body=summary_content,
            ContentType='application/json'
        )

        print("Processing completed successfully.")

        return {
            "statusCode": 200,
            "body": json.dumps("File processed successfully.")
        }

    except Exception as e:
        print(f"Error occurred: {str(e)}")
        raise e
