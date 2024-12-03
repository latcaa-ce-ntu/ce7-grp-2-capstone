terraform {
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment        = terraform.workspace # Dynamically sets the environment based on the workspace
      Owner              = "ce7-grp-2"
      Cohort             = "CE7"
      TerraformWorkspace = terraform.workspace # Adds a reference tag for easier identification
      Terraform          = true
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = "${var.name_prefix}-eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${var.name_prefix}-eks-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  
  # host                   = module.eks.cluster_endpoint
  # cluster_ca_certificate = base64decode(module.eks.kubeconfig_certificate_authority_data)
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  #   command     = "aws"
  # }
}
