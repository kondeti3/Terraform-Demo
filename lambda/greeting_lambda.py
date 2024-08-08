import json

def lambda_handler(event, context):
    body = json.loads(event['body'])
    name = body.get('name', 'User')
    return {
        'statusCode': 200,
        'body': json.dumps(f'How are you, {name}?')
    }
