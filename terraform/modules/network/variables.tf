# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnets Variables
variable "pub_subnet_cidrs" {
  description = "CIDR blocks for pub subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "pvt_subnet_cidrs" {
  description = "CIDR blocks for pvt subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "pub_azs" {
  description = "List of AZ for subnet"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "pvt_azs" {
  description = "List of AZ for subnet"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "allowed_ingress_cidr" {
  description = "CIDR block allowed for ingress to sec grp"
  type        = string
  default     = "0.0.0.0/0"
}

variable "name_prefix" {
  description = "Prefix to be added to resource names"
  type        = string
  default     = "ce7-grp-2"
}
