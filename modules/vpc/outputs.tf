output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.pub_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.pvt_subnets[*].id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_sg.id
}