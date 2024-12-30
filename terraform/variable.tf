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

# ----------------------------------------------------------------------------
# Below variables added for IAM, Web Api Gateway, Lambda, DynamoDB creation 
# ----------------------------------------------------------------------------

# ---------------------------------------------------
# For Dynamodb - Jokes
# ---------------------------------------------------
# variable "dynamodb_table_name" {
#   description = "dynamodb table name"
#   type        = string
#   default     = "jokes-db-v2"
# }

# ---------------------------------------------------
# For Dynamodb - HCA
# ---------------------------------------------------
variable "dynamodb_table_name" {
  description = "dynamodb table name"
  type        = string
  default     = "hca-db"
}

# ---------------------------------------------------
# For Lambda function - Jokes
# ---------------------------------------------------
# variable "lambda_function_name" {
#   description = "lambda function name"
#   type        = string
#   default     = "jokes-lambda-v2"
# }

# variable "lambda_file_name" {
#   description = "lambda file name"
#   type        = string
#   default     = "jokes-lambda"
# }

# ---------------------------------------------------
# For Lambda function - HCA
# ---------------------------------------------------
variable "lambda_function_name" {
  description = "lambda function name"
  type        = string
  default     = "hca-lambda"
}

variable "insert_record_lambda" {
  description = "insert records lambda function"
  type        = string
  default     = "hca-insert-records"
}

variable "python_version" {
  description = "Python version"
  type        = string
  default     = "python3.13"
}

# ---------------------------------------------------
# For IAM - Jokes
# ---------------------------------------------------
# variable "jokes_execution_role_name" {
#   description = "Jokes execution role name"
#   type        = string
#   default     = "jokes-execution-role-v2"
# }

# variable "jokes_policy_name" {
#   description = "Jokes policy name"
#   type        = string
#   default     = "jokes-policy-v2"
# }

# ---------------------------------------------------
# For IAM - HCA
# ---------------------------------------------------
variable "hca_execution_role_name" {
  description = "hca execution role name"
  type        = string
  default     = "hca-execution-role"
}

variable "hca_policy_name" {
  description = "hca policy name"
  type        = string
  default     = "hca-policy"
}

# ---------------------------------------------------
# For API Gateway - Jokes
# ---------------------------------------------------

# variable "rest_api_name" {
#   description = "Rest API name"
#   type        = string
#   default     = "jokes-restapi-v2"
# }

# ---------------------------------------------------
# For API Gateway - HCA
# ---------------------------------------------------

variable "rest_api_name" {
  description = "Rest API name"
  type        = string
  default     = "hca-restapi"
}

variable "rest_api_description" {
  description = "Rest API description"
  type        = string
  default     = "REST API to invoke lambda function for managing DynamoDB tables."
}

variable "stage_name" {
  description = "Stage name"
  type        = string
  default     = "dev"
}

variable "stage_name_desc" {
  description = "Stage name description"
  type        = string
  default     = "Development stage"
}
