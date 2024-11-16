# # Output Configuration - Displays key resource information after deployment

# output "vpc-id" {
#   # Outputs the VPC Name and ID
#   value = {
#     name = aws_vpc.main-vpc.tags["Name"]
#     id   = aws_vpc.main-vpc.id
#   }
# }

# output "pubsub-ids" {
#   # Outputs the IDs of the public subnets created
#   value = {
#     for subnet in aws_subnet.pub-subnets : subnet.tags["Name"] => subnet.id
#   }
# }
# output "pvtsub-ids" {
#   # Outputs the IDs of the private subnets created
#   value = {
#     for subnet in aws_subnet.pvt-subnets : subnet.tags["Name"] => subnet.id
#   }
# }

# output "ecs-sg-id" {
#   # Outputs the ID of the ECS security group
#   value = {
#     name = aws_security_group.ecs-sg.tags["Name"]
#     id   = aws_security_group.ecs-sg.id
#   }
# }

# output "ecr-repository-url" {
#   # Outputs the URL of the ECR repository created for ECS container images
#   value = {
#     name = aws_ecr_repository.ce7-g2-webapp.tags["Name"]
#     id   = aws_ecr_repository.ce7-g2-webapp.id
#   }
# }

# output "alb-dns-name" {
#   # Outputs the DNS name of the ALB
#   value = aws_alb.ce7-g2-alb.dns_name
# }

# output "alb-target-group-arn" {
#   # Outputs the ARN of the ALB target group
#   value = aws_lb_target_group.ce7-g2-targrp.arn
# }
