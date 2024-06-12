import json

def lambda_handler(event, context):
    # Your primary Lambda function logic
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
