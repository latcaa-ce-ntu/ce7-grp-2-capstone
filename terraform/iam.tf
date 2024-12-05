# ---------------------------------------------------
# IAM 
# ---------------------------------------------------

#  Define the jokes execution role
resource "aws_iam_role" "jokes_execution_role" {
  # name = var.jokes_execution_role_name
  name = "${var.name_prefix}-${var.jokes_execution_role_name}"

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

#  Define the jokes policy 
resource "aws_iam_policy" "jokes_policy" {
  # name = var.jokes_policy_name
  name = "${var.name_prefix}-${var.jokes_policy_name}"

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
        Resource = aws_dynamodb_table.jokes_table.arn
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
  role       = aws_iam_role.jokes_execution_role.name
  policy_arn = aws_iam_policy.jokes_policy.arn
}
