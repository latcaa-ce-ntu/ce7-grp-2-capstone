provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  pub_subnet_cidrs     = var.pub_subnet_cidrs
  pvt_subnet_cidrs     = var.pvt_subnet_cidrs
  pub_azs              = var.pub_azs
  pvt_azs              = var.pvt_azs
  allowed_ingress_cidr = var.allowed_ingress_cidr
}

# ALB Module
module "lb" {
  source             = "./modules/lb"
  lb_name            = "ce7-grp-2-lb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.vpc.eks_security_group_id]
  lb_listener_port   = 80
  lb_protocol        = "HTTP"
  lb_target_port     = 80
}

# ECR Module
module "ecr" {
  source             = "./modules/ecr"
  ecr_repo_name      = "ce7-grp-2-webapp"
  ecr_repository_url = module.ecr.repository_url
  # target_group_arn      = module.lb.target_group_arn
  # ecs_security_group    =
}

module "eks" {
  source               = "./modules/eks"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  lb_security_group_id = module.lb.security_group_id
  ecr_repository_url   = module.ecr.repository_url
}

# module "ecs" {
#   source                = "./modules/ecs"
#   vpc_id                = module.vpc.vpc_id
#   subnet_ids            = module.vpc.public_subnet_ids
#   lb_security_group_id  = module.lb.security_group_id
#   target_group_arn      = module.lb.target_group_arn
#   ecr_repository_url    = module.ecr.repository_url
#   ecs_security_group_id = module.ecs.ecs_security_group_id
# }