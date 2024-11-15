# Elastic Container Repo Variables
variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "ce7_g2_webapp"
}

variable "ecs_security_group_id" {
  description = "The ID of the security group created for the ALB"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}