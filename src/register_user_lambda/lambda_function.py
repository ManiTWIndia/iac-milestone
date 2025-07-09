import boto3
from os import getenv
from urllib.parse import parse_qsl


def lambda_handler(event, context):
    # query_string = dict(parse_qsl(event["rawQueryString"]))
    query_string = event.get("queryStringParameters")

    if not query_string:
        return {
            "statusCode": 400,
            "body": "Missing query parameters. Cannot register user."
        }
        
    client = boto3.resource("dynamodb")
    db_table = client.Table(getenv("DYNAMODB_TABLE_NAME"))
    try:
        response = db_table.put_item(Item=query_string)
        return { "message": "Registered User Successfully" }
    except Exception as error_details:
        print(error_details)
        return { "message": "Error registering user. Check Logs for more details." }
