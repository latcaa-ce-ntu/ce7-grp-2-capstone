# Create an Application Load Balancer (ALB)
resource "aws_alb" "ce7-g2-alb" {
  name               = var.alb-name
  internal           = false
  load_balancer_type = "application"

  # Attach the ECS security group to the ALB for access control
  security_groups = [aws_security_group.ecs-sg.id]

  # Specify the subnets the ALB will be associated with (public subnets)
  subnets = aws_subnet.pub-subnets[*].id

  # Tags for the ALB, useful for identification and management
  tags = {
    Name = var.alb-name
  }
}

# Data source to retrieve the details of the ALB created above
data "aws_alb" "ce7-g2-alb-data" {
  name = aws_alb.ce7-g2-alb.name
}

# Define a listener for the ALB to handle incoming traffic
resource "aws_lb_listener" "ce7-g2-listener" {
  load_balancer_arn = aws_alb.ce7-g2-alb.arn
  port              = var.alb-listener-port
  protocol          = var.alb-protocol

  # Default action for the listener is to forward traffic to a target group
  default_action {
    # Type of action, in this case, forwarding traffic to a target group
    type             = "forward"
    target_group_arn = aws_lb_target_group.ce7-g2-targrp.arn
  }
}

# Define a target group to register targets (e.g., ECS instances)
resource "aws_lb_target_group" "ce7-g2-targrp" {
  name        = "ce7-g2-targrp"
  port        = var.alb-target-port
  protocol    = var.alb-protocol
  target_type = "ip"
  vpc_id      = aws_vpc.main-vpc.id

  # Health check configuration to monitor the health of targets
  health_check {
    interval = 30

    # Path for health check requests
    path = "/"

    # Protocol for health checks (matches the listener protocol)
    protocol            = var.alb-protocol
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Data source to retrieve the details of the target group
data "aws_lb_target_group" "targrp-data" {
  name = aws_lb_target_group.ce7-g2-targrp.name
}
