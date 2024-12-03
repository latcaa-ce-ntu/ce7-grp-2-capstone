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
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "pvt_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
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

# variable "github_org" {
#   description = "GitHub organization name"
#   type        = string
# }

# variable "github_token" {
#   description = "GitHub Personal Access Token with organization package access"
#   type        = string
#   sensitive   = true
# }

# # Elastic Container Repo Variables
# variable "ecr_repository_url" {
#   type    = string
#   default = "public.ecr.aws/sctp-sandbox/ce7-grp-2-webapp-test2"
# }

variable "name_prefix" {
  description = "Prefix to be added to resource names"
  type        = string
  default     = "ce7-grp-2"
}