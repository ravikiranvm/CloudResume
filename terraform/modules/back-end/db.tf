# Create Dy.Db Table
resource "aws_dynamodb_table" "visitor_count" {
    name = "visitor_count"
    billing_mode = "PAY_PER_REQUEST" # On-demand billing
    hash_key = "PK"

    attribute {
      name = "PK"
      type = "S" #String
    }
}