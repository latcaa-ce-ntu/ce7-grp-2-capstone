# Elastic Container Repo Variables
variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "ce7_grp_2_webapp"
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}

# variable "ecs_security_group_id" {
#   description = "The ID of the security group created for the ECS tasks"
#   type        = string
# }

# variable "target_group_arn" {
#   description = "The ARN of the target group"
#   type        = string
# }
