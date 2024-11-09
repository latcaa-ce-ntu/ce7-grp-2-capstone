# Create an IAM role for ECS task execution to allow ECS tasks to pull images and perform operations
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "nov4-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Action allowing ECS tasks to assume the role
        Action = "sts:AssumeRole"

        # Principal service that can assume this role (ECS tasks)
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Effect = "Allow"

        # Statement ID 
        Sid = ""
      },
    ]
  })
}

# Attach the AmazonECSTaskExecutionRolePolicy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
