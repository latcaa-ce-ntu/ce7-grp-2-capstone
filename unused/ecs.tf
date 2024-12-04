# # Create ECS Cluster
# resource "aws_ecs_cluster" "ecs_cluster" {
#   name = "${var.name_prefix}-ecs-cluster-${terraform.workspace}"
#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }

# # Task Definition
# resource "aws_ecs_task_definition" "ecs_task" {
#   family                   = "${var.name_prefix}-ecs-task-def-family-${terraform.workspace}"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "1024"
#   memory                   = "3072"

#   container_definitions = jsonencode([
#     {
#       name  = "${var.name_prefix}-ecs-container-def-${terraform.workspace}"
#       image = "${aws_ecr_repository.ecr_repo.name}:latest"
#       portMappings = [
#         {
#           name          = "${var.name_prefix}-80-tcp"
#           containerPort = 80
#           hostPort      = 80
#           protocol      = "tcp"
#           appProtocol   = "http"
#         }
#       ]
#       essential = true
#       # logConfiguration = {
#       #   logDriver = "awslogs"
#       #   options = {
#       #     awslogs-group         = "/ecs/${var.name_prefix}-ecs_task_def_family-${terraform.workspace}"
#       #     awslogs-region        = "us-east-1"
#       #     awslogs-stream-prefix = "ecs"
#       #     awslogs-create-group  = "true"
#       #     mode                  = "non-blocking"
#       #     max-buffer-size       = "25m"
#       #   }
#       # }
#     }
#   ])
#   #checkov:skip=CKV_AWS_336:Ensure ECS containers are limited to read-only access to root filesystems
# }

# # ECS Service
# resource "aws_ecs_service" "hello_world" {
#   name            = "${var.name_prefix}-ecs-service-${terraform.workspace}"
#   cluster         = aws_ecs_cluster.ecs_cluster.id
#   task_definition = aws_ecs_task_definition.ecs_task.arn
#   launch_type     = "FARGATE"
#   desired_count   = 2

#   network_configuration {
#     subnets          = module.vpc.public_subnets # Replace with your subnet IDs
#     assign_public_ip = true
#     security_groups  = [aws_security_group.sg-allow-ssh-http-https.id]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.lb_tg.arn
#     container_name   = "${var.name_prefix}-ecs-container-def-${terraform.workspace}"
#     container_port   = 80
#   }
#   #checkov:skip=CKV_AWS_333:Ensure ECS services do not have public IP addresses assigned to them automatically
# }

# # Application Load Balancer
# resource "aws_lb" "alb" {
#   name                       = "${var.name_prefix}-alb-${terraform.workspace}"
#   internal                   = false
#   load_balancer_type         = "application"
#   security_groups            = [aws_security_group.sg-allow-ssh-http-https.id]
#   subnets                    = module.vpc.public_subnets # Replace with your subnet IDs
#   drop_invalid_header_fields = true
#   #checkov:skip=CKV_AWS_150:Ensure that Load Balancer has deletion protection enabled
#   #checkov:skip=CKV_AWS_91:Ensure the ELBv2 (Application/Network) has access logging enabled
#   #checkov:skip=CKV2_AWS_20:Ensure that ALB redirects HTTP requests into HTTPS ones
#   #checkov:skip=CKV2_AWS_28:Ensure public facing ALB are protected by WAF
# }

# # ALB Listener
# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.lb_tg.arn
#   }
#   #checkov:skip=CKV_AWS_2:Ensure ALB protocol is HTTPS
#   #checkov:skip=CKV_AWS_103:Ensure that load balancer is using at least TLS 1.2
# }

# # ALB Target Group
# resource "aws_lb_target_group" "lb_tg" {
#   name        = "${var.name_prefix}-alb-tg-${terraform.workspace}"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.vpc.vpc_id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = "3"
#     interval            = "240"
#     protocol            = "HTTP"
#     matcher             = "200"
#     timeout             = "3"
#     path                = "/"
#     unhealthy_threshold = "2"
#   }
#   #checkov:skip=CKV_AWS_378:Ensure AWS Load Balancer doesn't use HTTP protocol
# }