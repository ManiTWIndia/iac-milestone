import json

def lambda_handler(event, context):
    """
    A simple handler that returns a 'Hello world' message in the
    format expected by API Gateway v2.
    """
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Hello world"
        })
    }