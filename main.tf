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
module "alb" {
  source             = "./modules/alb"
  alb_name           = "ce7-g2-alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.vpc.ecs_security_group_id]
  alb_listener_port  = 80
  alb_protocol       = "HTTP"
  alb_target_port    = 80
}

# ECR Module
module "ecr" {
  source                = "./modules/ecr"
  ecr_repo_name         = "ce7-g2-webapp"
  ecs_security_group_id = module.ecs.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  ecr_repository_url    = module.ecr.repository_url
}

module "ecs" {
  source                = "./modules/ecs"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  ecr_repository_url    = module.ecr.repository_url
  ecs_security_group_id = module.ecs.ecs_security_group_id
}