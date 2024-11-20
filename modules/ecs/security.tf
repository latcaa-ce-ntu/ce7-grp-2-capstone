# resource "aws_security_group" "ecs_sg" {
#   name_prefix = "ce7-g2-ecs-sg"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [var.lb_security_group_id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "ce7_g2_ecs_sg"
#   }
# }