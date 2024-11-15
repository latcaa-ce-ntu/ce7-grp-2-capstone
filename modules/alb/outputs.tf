output "alb_dns_name" {
  # Outputs the DNS name of the ALB
  value = aws_alb.ce7_g2_alb.dns_name
}

output "alb_target_group_arn" {
  # Outputs the ARN of the ALB target group
  value = aws_lb_target_group.ce7_g2_targrp.arn
}

output "security_group_id" {
  description = "The ID of the security group created for the ALB"
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.ce7_g2_targrp.arn
}

output "alb_arn" {
  description = "The ARN of the application load balancer"
  value       = aws_lb.ce7_g2_alb.arn
}