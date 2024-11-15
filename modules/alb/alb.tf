# Create an Application Load Balancer (ALB)
resource "aws_alb" "ce7_g2_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"

  # Attach the ECS security group to the ALB for access control
  security_groups = var.security_group_ids

  # Specify the subnets the ALB will be associated ith (pub)
  subnets         = var.public_subnet_ids

  # Associate the ALB with the VPC
  # vpc_id          = var.vpc_id

  # Tags for the ALB, useful for identification and management
  tags = {
    Name = var.alb_name
  }
}

# Data source to retrieve the details of the ALB created above
data "aws_alb" "ce7_g2_alb_data" {
  name = aws_alb.ce7_g2_alb.name
}

# Define a listener for the ALB to handle incoming traffic
resource "aws_lb_listener" "ce7_g2_listener" {
  load_balancer_arn = aws_alb.ce7_g2_alb.arn
  port              = var.alb_listener_port
  protocol          = var.alb_protocol

  # Default action for the listener is to forward traffic to a target group
  default_action {
    # Type of action, in this case, forwarding traffic to a target group
    type             = "forward"
    target_group_arn = aws_lb_target_group.ce7_g2_targrp.arn
  }
}

# Define a target group to register targets (e.g., ECS instances)
resource "aws_lb_target_group" "ce7_g2_targrp" {
  name        = "ce7-g2-targrp"
  port        = var.alb_target_port
  protocol    = var.alb_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  # Health check configuration to monitor the health of targets
  health_check {
    interval = 30

    # Path for health check requests
    path = "/"

    # Protocol for health checks (matches the listener protocol)
    protocol            = var.alb_protocol
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Data source to retrieve the details of the target group
data "aws_lb_target_group" "targrp_data" {
  name = aws_lb_target_group.ce7_g2_targrp.name
}
