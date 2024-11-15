variable "vpc_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID of the ALB"
  type = string
}
