# ---------------------------------------------------
# Lambda function
# ---------------------------------------------------

resource "aws_dynamodb_table" "jokes_table" {
  # name         = var.dynamodb_table_name
  name = "${var.name_prefix}-${var.dynamodb_table_name}"

  billing_mode = "PAY_PER_REQUEST"

  # Numeric type for the primary key
  attribute {
    name = "Id"
    type = "N"
  }

  # Define the primary key
  hash_key = "Id"

  tags = {
    Environment = "dev"
    Team        = "group-2"
  }
}
