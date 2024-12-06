# Create HTTP API
resource "aws_apigatewayv2_api" "count_api" {
    name = "count_api"
    protocol_type = "HTTP"
}

# Create a route for the HTTP api
resource "aws_apigatewayv2_route" "count_api_route" {
    api_id = aws_apigatewayv2_api.count_api.id
    route_key = "GET /visitor_count"
    target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Create an integration with visitor count function
resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id = aws_apigatewayv2_api.count_api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.visitor_count_function.invoke_arn
    integration_method = "POST"
}

# Permission to allow API gateway to invoke lambda
resource "aws_lambda_permission" "for_count_api" {
    statement_id = "AllowHttpAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.visitor_count_function.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.count_api.execution_arn}/*/*"
}

# Deploy the count api to stage
resource "aws_apigatewayv2_stage" "prod_stage" {
    api_id = aws_apigatewayv2_api.count_api.id
    name = "prod"
    auto_deploy = true
}