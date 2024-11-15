variable "alb_name" {
  description = "Name of ALB"
  type        = string
  default     = "ce7_g2_alb"
}

variable "alb_listener_port" {
  description = "Port for ALB Listener"
  type        = number
  default     = 80
}

variable "alb_target_port" {
  description = "Port for ALB target group"
  type        = number
  default     = 80
}

variable "alb_protocol" {
  description = "Protocol for ALB listener and target group"
  type        = string
  default     = "HTTP"
}

variable "security_group_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC to associate with ALB"
  type        = string
}