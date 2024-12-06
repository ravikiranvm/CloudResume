#Zip the python code as a package
data "archive_file" "lambda" {
    type = "zip"
    source_file = "${path.module}/update_count.py"
    output_path = "${path.module}/update_count_function.zip"
}

#Create Lambda function to access visitor_count table and get the total count

resource "aws_lambda_function" "visitor_count_function" {
    function_name = "visitor_count"
    runtime = "python3.9"
    role = aws_iam_role.visitor_count_exec.arn
    handler = "update_count.lambda_handler"
    filename = "${path.module}/update_count_function.zip"

    source_code_hash = data.archive_file.lambda.output_base64sha256

}

#Create Execution role for visitor_count lambda
resource "aws_iam_role" "visitor_count_exec" {
    name = "visitor_count_exec"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
}

#Attach dy.db access policy to the exec role"
resource "aws_iam_role_policy_attachment" "visitor_count_table" {
    role = aws_iam_role.visitor_count_exec.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"

}

