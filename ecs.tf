# Create an ECS Cluster to group ECS services
resource "aws_ecs_cluster" "ce7-g2-ecs" {
  name = "ce7-g2-ecs-cluster"
}

# Create an ECS Task Definition which describes how the container runs
resource "aws_ecs_task_definition" "ce7-g2-ecs-task" {
  # Family name for the ECS task definition, used for versioning and grouping tasks
  family = "ce7-g2-ecs-task"

  # IAM role used by ECS tasks to pull images and execute operations
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn

  # Container definition in JSON format, describing the containers in the task
  container_definitions = jsonencode([{
    name = "ce7-g2-ecs-container"

    # URL of the image stored in ECR, with the "latest" tag
    image  = "${aws_ecr_repository.ce7-g2-webapp.repository_url}:latest"
    memory = 512
    cpu    = 256

    # Mark the container as essential, meaning the task won't stop if it fails
    essential = true

    # Port mappings for the container, mapping container port 80 to host port 80
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])

  # Specifies that this task is compatible with Fargate (serverless compute)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "1024"
  cpu                      = "512"
}

# Create an ECS Service to run the task on Fargate
resource "aws_ecs_service" "ce7-g2-ecs-svc" {
  name            = "ce7-g2-esc-service"
  cluster         = aws_ecs_cluster.ce7-g2-ecs.id
  task_definition = aws_ecs_task_definition.ce7-g2-ecs-task.arn

  # Desired number of running instances
  desired_count = 1
  launch_type   = "FARGATE"

  # Network configuration for the service
  network_configuration {
    # Subnets the service tasks will run in (public subnets in this case)
    subnets         = [aws_subnet.pub-subnets[0].id, aws_subnet.pub-subnets[1].id, aws_subnet.pub-subnets[2].id]
    security_groups = [aws_security_group.ecs-sg.id]

    # Assign a public IP to the tasks so they can be accessed from the internet
    assign_public_ip = true
  }

  # Load balancer configuration for the ECS service
  load_balancer {
    # Target group ARN for routing traffic to the containers
    target_group_arn = aws_lb_target_group.ce7-g2-targrp.arn
    container_name   = "ce7-g2-ecs-container"
    container_port   = 80
  }
}
