# ---------------------------------------------------
# Lambda function - Jokes
# ---------------------------------------------------
# resource "aws_lambda_function" "jokes_lambda" {
#   # function_name = var.lambda_function_name 
#   function_name = "${var.name_prefix}-${var.lambda_function_name}"

#   handler  = "${var.name_prefix}-${var.lambda_file_name}.lambda_handler"
#   runtime  = var.python_version
#   role     = aws_iam_role.jokes_execution_role.arn
#   filename = "${var.name_prefix}-${var.lambda_file_name}.zip"

#   environment {
#     variables = {
#       TABLE_NAME = aws_dynamodb_table.jokes_table.name
#     }
#   }
# }

# ---------------------------------------------------
# Lambda function - HCA
# ---------------------------------------------------
resource "aws_lambda_function" "hca_lambda" {

  function_name = "${var.name_prefix}-${var.lambda_function_name}"
  handler       = "${var.name_prefix}-${var.lambda_function_name}.lambda_handler"
  runtime       = var.python_version
  role          = aws_iam_role.hca_execution_role.arn
  filename      = "${var.name_prefix}-${var.lambda_function_name}.zip"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.hca_table.name
    }
  }

}

# # ----------------------------------------------------------------------------------------------------

# Lambda Function Configuration Summary

# Creates AWS Lambda function for jokes service with:
# 1.  Custom handler with prefix
# 2.  Python runtime
# 3.  IAM role access
# 4.  DynamoDB integration via environment variable

# Components
# - Customized naming with prefix
# - Links to IAM execution role
# - Manages jokes data through DynamoDB
# - Deployed via zip package
