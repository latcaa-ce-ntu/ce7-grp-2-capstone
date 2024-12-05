# ---------------------------------------------------
# Lambda function
# ---------------------------------------------------
resource "aws_lambda_function" "jokes_lambda" {
  # function_name = var.lambda_function_name 
  function_name = "${var.name_prefix}-${var.lambda_function_name}"

  handler  = "${var.name_prefix}-${var.lambda_file_name}.lambda_handler"
  runtime  = var.python_version
  role     = aws_iam_role.jokes_execution_role.arn
  filename = "${var.name_prefix}-${var.lambda_file_name}.zip"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.jokes_table.name
    }
  }
}
