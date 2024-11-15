provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
}

# ALB Module
module "alb" {
  source             = "./modules/alb"
  public_subnet_ids  = module.vpc.public_subnet_ids
  vpc_id             = module.vpc.vpc_id
  security_group_ids = module.vpc.ecs_security_group_id
}

# ECR Module
module "ecr" {
  source                = "./modules/ecr"
  ecs_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  ecr_repository_url    = module.ecr.repository_url
}

module "ecs" {
  source                = "./modules/ecs"
  subnet_ids            = module.vpc.public_subnet_ids
  vpc_id                = module.vpc.vpc_id
  ecs_security_group_id = module.alb.security_group_id
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  ecr_repository_url    = module.ecr.repository_url
}