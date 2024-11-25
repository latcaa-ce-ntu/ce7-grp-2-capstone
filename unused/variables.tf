# Provider Variables
variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pub_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "pvt_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "pub_azs" {
  description = "Availability zones for public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "pvt_azs" {
  description = "Availability zones for private subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "allowed_ingress_cidr" {
  description = "CIDR block allowed for ingress"
  type        = string
  default     = "0.0.0.0/0"
}



# # VPC Variables
# variable "vpc-cidr" {
#   description = "CIDR block for VPC"
#   type        = string
#   default     = "10.0.0.0/16"
# }

# # Subnets Variables
# variable "pub-subnet-cidrs" {
#   description = "CIDR blocks for pub subnets"
#   type        = list(string)
#   default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# }

# variable "pvt-subnet-cidrs" {
#   description = "CIDR blocks for pvt subnets"
#   type        = list(string)
#   default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
# }

# variable "pub-azs" {
#   description = "List of AZ for subnet"
#   type        = list(string)
#   default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
# }

# variable "pvt-azs" {
#   description = "List of AZ for subnet"
#   type        = list(string)
#   default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
# }

# variable "allowed-ingress-cidr" {
#   description = "CIDR block allowed for ingress to sec grp"
#   type        = string
#   default     = "0.0.0.0/0"
# }

# # Elastic Container Repo Variables
# variable "ecr-repo-name" {
#   description = "Name of the ECR repository"
#   type        = string
#   default     = "ce7-g2-webapp"
# }

# Elastic Container Service Variables

# # Application Load Balancer Variables
# variable "alb-name" {
#   description = "Name of ALB"
#   type        = string
#   default     = "ce7-g2-alb"
# }

# variable "alb-listener-port" {
#   description = "Port for ALB Listener"
#   type        = number
#   default     = 80
# }

# variable "alb-target-port" {
#   description = "Port for ALB target group"
#   type        = number
#   default     = 80
# }

# variable "alb-protocol" {
#   description = "Protocol for ALB listener and target group"
#   type        = string
#   default     = "HTTP"
# }