output "alb_arn" {
  value = aws_alb.ce7_g2_alb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.ce7_g2_targrp.arn
}

output "security_group_id" {
  value = aws_security_group.alb_sg.id
}