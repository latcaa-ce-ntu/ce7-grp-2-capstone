# Main Terraform Configuration File
# Network Module Configuration - Creates the VPC and associated networking components
module "network" {
  source               = "./modules/network"
  vpc_cidr             = var.vpc_cidr
  pub_subnet_cidrs     = var.pub_subnet_cidrs
  pvt_subnet_cidrs     = var.pvt_subnet_cidrs
  pub_azs              = var.pub_azs
  pvt_azs              = var.pvt_azs
  allowed_ingress_cidr = var.allowed_ingress_cidr
}

# EKS (Elastic Kubernetes Service) Module Configuration - Sets up the Kubernetes cluster and related components
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  subnet_ids         = concat(module.network.public_subnet_ids, module.network.private_subnet_ids)
  # github_token       = var.github_token
  depends_on = [module.network]
}

# Infrastructure Overview:
#
# 1. Network Module:
#    - Creates VPC and networking infrastructure
#    - Sets up public and private subnets
#    - Configures routing and security
#    - Enables high availability across AZs
#
# 2. EKS Module:
#    - Deploys Kubernetes cluster
#    - Sets up node groups
#    - Configures IAM roles and policies
#    - Integrates with VPC networking
#
# 3. Module Dependencies:
#    - EKS module depends on Network module
#    - Uses outputs from Network module for configuration
#    - Ensures proper resource ordering