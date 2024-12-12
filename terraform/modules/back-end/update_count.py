import boto3, json
from decimal import Decimal

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor_count')

def convert_decimal(obj):
    if isinstance(obj, Decimal):
        # Convert to int if no decimal part
        if obj % 1 == 0:
            return int(obj)
        return float(obj)
    raise TypeError("Object of type Decimal is not JSON serializable")

def lambda_handler(event, context):
    try:
        # Retrieve the current 'updated_total_count' value
        response = table.get_item(Key={'PK': 'visitor_count'})  # Use the new key name 'PK' and value
        
        if 'Item' in response:
            # Get the current value of 'updated_total_count'
            current_count = response['Item'].get('updated_total_count', Decimal(0))
            
            # Increment the count
            updated_count = current_count + Decimal(1)
            
            # Update the 'updated_total_count' attribute only
            table.update_item(
                Key={'PK': 'visitor_count'},  # Use the same key for update
                UpdateExpression='SET updated_total_count = :val1',
                ExpressionAttributeValues={':val1': updated_count}
            )
            
            return {
                'statusCode': 200,
                'headers': {
                    "Access-Control-Allow-Origin": "https://raviki.online",  # CORS header
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",  # Allowed methods
                    "Access-Control-Allow-Headers": "Content-Type"  # Allowed headers
                },
                'body': json.dumps({'updated_total_count': convert_decimal(updated_count)})
            }
        else:
            # If the item doesn't exist, create it with 'updated_total_count' set to 1
            table.put_item(
                Item={
                    'PK': 'visitor_count',
                    'updated_total_count': Decimal(1)
                }
            )
            
            return {
                'statusCode': 200,
                'headers': {
                    "Access-Control-Allow-Origin": "https://raviki.online",  # CORS header
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",  # Allowed methods
                    "Access-Control-Allow-Headers": "Content-Type"  # Allowed headers
                },
                'body': json.dumps({'updated_total_count': 1})
            }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                "Access-Control-Allow-Origin": "https://raviki.online",  # CORS header
                "Access-Control-Allow-Methods": "GET, POST, OPTIONS",  # Allowed methods
                "Access-Control-Allow-Headers": "Content-Type"  # Allowed headers
            },
            'body': json.dumps(f"Error updating data: {str(e)}")
        }
