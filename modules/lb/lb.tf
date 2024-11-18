# Application Load Balancer (ALB)
resource "aws_lb" "ce7_grp_2_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups = var.security_group_ids
  subnets = var.public_subnet_ids

  tags = {
    Name = var.lb_name
  }
}

# Data source to retrieve the details of the ALB created above
data "aws_lb" "ce7_grp_2_lb_data" {
  name = aws_lb.ce7_grp_2_lb.name
}

resource "aws_lb_listener" "ce7_grp_2_listener" {
  load_balancer_arn = aws_lb.ce7_grp_2_lb.arn
  port              = var.lb_listener_port
  protocol          = var.lb_protocol

  # Default action for the listener is to forward traffic to a target group
  default_action {
    # Type of action, in this case, forwarding traffic to a target group
    type             = "forward"
    target_group_arn = aws_lb_target_group.ce7_grp_2_targrp.arn
  }
}

# Define a target group to register targets (e.g., ECS instances)
resource "aws_lb_target_group" "ce7_grp_2_targrp" {
  name        = "ce7-grp-2-targrp"
  port        = var.lb_target_port
  protocol    = var.lb_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval = 30

    # Path for health check requests
    path = "/"
    protocol            = var.lb_protocol
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Data source to retrieve the details of the target group
data "aws_lb_target_group" "targrp_data" {
  name = aws_lb_target_group.ce7_grp_2_targrp.name
}
