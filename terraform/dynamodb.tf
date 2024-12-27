# ---------------------------------------------------
# DynamoDB Table Configuration - Jokes
# ---------------------------------------------------

# resource "aws_dynamodb_table" "jokes_table" {
#   name = "${var.name_prefix}-${var.dynamodb_table_name}"

#   billing_mode = "PAY_PER_REQUEST"

#   # Numeric type for the primary key
#   attribute {
#     name = "Id"
#     type = "N"
#   }

#   # Define the primary key
#   hash_key = "Id"

#   tags = {
#     Environment = "dev"
#     Team        = "group-2"
#   }
# }

# ---------------------------------------------------
# DynamoDB Table Configuration - HCA
# ---------------------------------------------------

resource "aws_dynamodb_table" "hca_table" {

  name         = "${var.name_prefix}-${var.dynamodb_table_name}"
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

resource "aws_lambda_function" "insert_to_dynamodb" {

  function_name = "${var.name_prefix}-${var.insert_record_lambda}"
  handler       = "${var.name_prefix}-${var.insert_record_lambda}.insert_record"
  runtime       = var.python_version
  role          = aws_iam_role.hca_execution_role.arn
  filename      = "${var.name_prefix}-${var.insert_record_lambda}.zip"
  timeout       = 30

}

# # ----------------------------------------------------------------------------------------------------

# Summary
# Creates a DynamoDB table for storing jokes with pay-per-request billing and numeric ID as primary key.

# Code Steps

# 1.  Table Configuration:
# - Sets pay-per-request billing mode
# - Defines numeric 'Id' as primary key


# 2.  Attribute Definition:

# - Configures 'Id' as Number type
# - Sets as hash key for table


# 3.  Resource Tagging:
# - Adds Environment tag as 'dev'
# - Adds Team tag as 'group-2'

# Key Features
# - Serverless pricing model
# - Numeric primary key
# - Environment and team identification
