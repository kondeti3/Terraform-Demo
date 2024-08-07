import json

def lambda_handler(event, context):
    try:
        if event['httpMethod'] == 'GET':
            return {
                'statusCode': 200,
                'body': 'Welcome to the Lambda'
            }
        elif event['httpMethod'] == 'POST':
            body = json.loads(event['body'])
            name = body.get('name', 'User')
            return {
                'statusCode': 200,
                'body': json.dumps(f'How are you today, {name}?')
            }
        else:
            return {
                'statusCode': 400,
                'body': 'Unsupported method'
            }
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': 'Internal server error'
        }
