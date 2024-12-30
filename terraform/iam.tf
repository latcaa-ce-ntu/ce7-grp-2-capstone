# ---------------------------------------------------
# IAM Configuration for Lambda and DynamoDB - Jokes
# ---------------------------------------------------

# #  Define the jokes execution role
# resource "aws_iam_role" "jokes_execution_role" {
#   # name = var.jokes_execution_role_name
#   name = "${var.name_prefix}-${var.jokes_execution_role_name}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# #  Define the jokes policy 
# resource "aws_iam_policy" "jokes_policy" {
#   # name = var.jokes_policy_name
#   name = "${var.name_prefix}-${var.jokes_policy_name}"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "dynamodb:GetItem",
#           "dynamodb:PutItem",
#           "dynamodb:UpdateItem",
#           "dynamodb:DeleteItem",
#           "dynamodb:Scan",
#           "dynamodb:Query"
#         ]
#         Effect   = "Allow"
#         Resource = aws_dynamodb_table.jokes_table.arn
#       },
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Effect   = "Allow"
#         Resource = "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_policy" {
#   role       = aws_iam_role.jokes_execution_role.name
#   policy_arn = aws_iam_policy.jokes_policy.arn
# }

# ---------------------------------------------------
# IAM Configuration for Lambda and DynamoDB - HCA
# ---------------------------------------------------

#  Define the hca execution role
resource "aws_iam_role" "hca_execution_role" {

  name = "${var.name_prefix}-${var.hca_execution_role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#  Define the hca policy 
resource "aws_iam_policy" "hca_policy" {

  name = "${var.name_prefix}-${var.hca_policy_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.hca_table.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.hca_execution_role.name
  policy_arn = aws_iam_policy.hca_policy.arn
}


# # ----------------------------------------------------------------------------------------------------

# Summary

# Creates IAM role and policy for Lambda to interact with DynamoDB and CloudWatch logs.

# Code Steps
# 1.  Creates IAM Role:
# - Sets up role name with prefix
# - Enables Lambda service to assume this role
# - Establishes basic trust relationship


# 2.  Creates IAM Policy:
# - Configures DynamoDB permissions (Get, Put, Update, Delete, Scan, Query)
# - Adds CloudWatch logging permissions
# - Links to specific DynamoDB table ARN


# 3.  Attaches Policy to Role:
# - Connects the policy to the execution role
# - Completes permission setup for Lambda

# Permissions Granted
# - DynamoDB: Full CRUD operations
# - CloudWatch: Log creation and management
# - Lambda: Assume role capability
