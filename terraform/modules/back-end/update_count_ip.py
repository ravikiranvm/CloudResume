import boto3, json
from decimal import Decimal
import time

dynamodb = boto3.resource('dynamodb')
count_table = dynamodb.Table('visitor_count')
ip_table = dynamodb.Table('visitor_ips')

def convert_decimal(obj):
    if isinstance(obj, Decimal):
        return int(obj) if obj % 1 == 0 else float(obj)
    raise TypeError("Object of type Decimal is not JSON serializable")

def extract_client_ip(event):
    headers = event.get("headers", {})
    x_forwarded_for = headers.get("X-Forwarded-For") or headers.get("x-forwarded-for")
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0].strip()
    return "unknown"

def lambda_handler(event, context):
    try:
        client_ip = extract_client_ip(event)

        # Check if IP already recorded
        ip_check = ip_table.get_item(Key={'ip': client_ip})
        if 'Item' in ip_check:
            # IP already counted
            response = count_table.get_item(Key={'PK': 'counter'})
            current_count = response['Item']['count'] if 'Item' in response else Decimal(0)
            return {
                'statusCode': 200,
                'headers': {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type"
                },
                'body': json.dumps({'updated_total_count': convert_decimal(current_count)})
            }

        # IP not recorded, increment count
        expire_at = int(time.time()) + 7 * 24 * 3600  # TTL: 7 days from now
        ip_table.put_item(Item={'ip': client_ip, 'expire_at': expire_at})

        # Update count atomically
        count_table.update_item(
            Key={'PK': 'counter'},
            UpdateExpression='ADD count :inc',
            ExpressionAttributeValues={':inc': Decimal(1)},
        )

        # Fetch updated count
        response = count_table.get_item(Key={'PK': 'counter'})
        updated_count = response['Item']['count']

        return {
            'statusCode': 200,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
                },
            'body': json.dumps({'updated_total_count': convert_decimal(updated_count)})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            'body': json.dumps(f"Error: {str(e)}")
        }
