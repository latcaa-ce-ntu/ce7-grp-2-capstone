variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecr_repository_url" {
  type = string
}

variable "lb_name" {
  description = "Name of LB"
  type        = string
  default     = "ce7-grp-2-lb"
}

variable "lb_listener_port" {
  description = "Port for LB Listener"
  type        = number
  default     = 80
}

variable "lb_target_port" {
  description = "Port for LB target group"
  type        = number
  default     = 80
}

variable "lb_protocol" {
  description = "Protocol for LB listener and target group"
  type        = string
  default     = "HTTP"
}

variable "name_prefix" {
  description = "Prefix to be added to resource names"
  type        = string
  default     = "ce7-grp-2"
}