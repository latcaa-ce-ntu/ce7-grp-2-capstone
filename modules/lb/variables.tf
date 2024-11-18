variable "lb_name" {
  description = "Name of LB"
  type        = string
  default     = "ce7_grp_2_lb"
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

variable "security_group_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC to associate with LB"
  type        = string
}