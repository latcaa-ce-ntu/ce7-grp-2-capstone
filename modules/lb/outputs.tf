output "lb_arn" {
  value = aws_lb.ce7_grp_2_lb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.ce7_grp_2_targrp.arn
}

output "security_group_id" {
  value = aws_security_group.lb_sg.id
}