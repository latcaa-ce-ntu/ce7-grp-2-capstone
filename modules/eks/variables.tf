variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}

variable "lb_security_group_id" {
  description = "Security Group ID of the LB"
  type        = string
}

variable "ecr_repository_url" {
  type = string
}