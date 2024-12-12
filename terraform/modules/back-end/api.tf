
# Create HTTP API
resource "aws_api_gateway_rest_api" "count_api" {
    name = "count_api"
}
# Create a resource path for the visitor_count api
resource "aws_api_gateway_resource" "visitor_count_resource" {
    rest_api_id = aws_api_gateway_rest_api.count_api.id
    parent_id = aws_api_gateway_rest_api.count_api.root_resource_id
    path_part = "visitor_count"
}
# Create a Method for GET request
resource "aws_api_gateway_method" "post_visitor" {
    rest_api_id = aws_api_gateway_rest_api.count_api.id
    resource_id = aws_api_gateway_resource.visitor_count_resource.id
    http_method = "GET"
    authorization = "NONE"
}

# Integration with lambda
resource "aws_api_gateway_integration" "lambda_integration" {
    rest_api_id = aws_api_gateway_rest_api.count_api.id
    resource_id = aws_api_gateway_resource.visitor_count_resource.id
    http_method = aws_api_gateway_method.post_visitor.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.visitor_count_function.invoke_arn
}
# Permission for API gateway to invoke lambda
resource "aws_lambda_permission" "for_count_api" {
    statement_id = "AllowRESTApiGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.visitor_count_function.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_api_gateway_rest_api.count_api.execution_arn}/*/*"
}
#Deploy the API to prod stage
resource "aws_api_gateway_deployment" "count_api_deployment" {
    rest_api_id = aws_api_gateway_rest_api.count_api.id
    depends_on = [ aws_api_gateway_integration.lambda_integration, aws_api_gateway_method.post_visitor ]
}
# Stage the API to prod
resource "aws_api_gateway_stage" "count_api_staging" {
    rest_api_id = aws_api_gateway_rest_api.count_api.id
    deployment_id = aws_api_gateway_deployment.count_api_deployment.id
    stage_name = "prod"
}
# Add nethid level throttling
resource "aws_api_gateway_method_settings" "count_api_settings" {
    rest_api_id = aws_api_gateway_rest_api.count_api.id
    stage_name = aws_api_gateway_stage.count_api_staging.stage_name
    method_path = "*/*" # This applies to all methods
    settings {
        throttling_rate_limit = 50 # Request per second
        throttling_burst_limit = 25 # Burst requests
 }
}