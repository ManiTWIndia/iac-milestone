import boto3
from os import getenv
from urllib.parse import parse_qsl


def lambda_handler(event, context):
    s3_client = boto3.client("s3")
    try:
        query_string = event.get("queryStringParameters")

        if not query_string:
            return {
                "statusCode": 400,
                "body": "Missing query parameters. Cannot verify user."
            }
        item_found = is_key_in_db(db_key=query_string)
        result_file = "index.html" if item_found else "error.html"
        response = s3_client.get_object(Bucket=getenv("S3_BUCKET_NAME"), Key=result_file)
        html_body = response["Body"].read().decode("utf-8")
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "text/html"},
            "body": html_body,
        }
    except Exception as error_details:
        print(error_details)
        return "Error verifying user. Check Logs for more details."


def is_key_in_db(db_key):
    db_client = boto3.resource("dynamodb")
    db_table = db_client.Table(getenv("DYNAMODB_TABLE_NAME"))
    try:
        response = db_table.get_item(Key=db_key)
        if "Item" not in response:
            print(f"Item with key: {db_key} not found")
            return False
    except Exception as err:
        print(f"Error Getting Item: {err}")
        return False
    else:
        return True
