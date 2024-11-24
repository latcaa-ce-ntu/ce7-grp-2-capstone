module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"

  name = "${var.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs                  = ["${var.region}a", "${var.region}b"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_names = ["${var.name_prefix}-private-subnet-az1", "${var.name_prefix}-private-subnet-az2"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnet_names  = ["${var.name_prefix}-public-subnet-az1", "${var.name_prefix}-public-subnet-az2"]

  igw_tags = {
    Name = "${var.name_prefix}-igw"
  }
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}