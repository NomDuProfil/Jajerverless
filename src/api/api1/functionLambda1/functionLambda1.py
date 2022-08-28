import json

def buildResponse(code, message, json_body=False):
    if json_body:
        message = json.dumps(message)
    return {
        'statusCode': code,
        'body': message,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }

def lambda_handler(event, context):
    return buildResponse(200, 'Example response')