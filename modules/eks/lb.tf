# Application Load Balancer (ALB)
resource "aws_lb" "ce7_grp_2_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnet_ids

  # Enable access logging
  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "loadbalancer-logs"
    enabled = true
  }
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
  name        = "${var.name_prefix}-targrp"
  port        = var.lb_target_port
  protocol    = var.lb_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval = 30

    # Path for health check requests
    path                = "/"
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

# S3 bucket for ALB logs
resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.name_prefix}-alb-logs"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket policy to allow ALB to write logs
resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root"  # ALB account ID for us-east-1
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
      }
    ]
  })
}

# Get current account ID
data "aws_caller_identity" "current" {}