# Create the main EKS cluster
resource "aws_eks_cluster" "ce7_grp_2_eks" {
  name     = "${var.name_prefix}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn # IAM role for cluster management
  version  = "1.31"                            # Kubernetes version

  # Network settings for the cluster
  vpc_config {
    subnet_ids              = var.subnet_ids                         # Subnets where cluster resources will be placed
    endpoint_private_access = true                                   # Allow internal VPC access to Kubernetes API
    endpoint_public_access  = true                                   # Allow internet access to Kubernetes API
    security_group_ids      = [aws_security_group.eks_cluster_sg.id] # Network access rules
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP" # Options: API, CONFIG_MAP, or API_AND_CONFIG_MAP
  }

  # Ensure IAM role and security group are ready before creating cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_security_group.eks_cluster_sg
  ]

  tags = {
    Name = "${var.name_prefix}-eks-cluster"
  }
}

# Create group of worker nodes to run applications
resource "aws_eks_node_group" "ce7_grp_2_node_group" {
  cluster_name    = aws_eks_cluster.ce7_grp_2_eks.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn # IAM role for node permissions
  subnet_ids      = var.private_subnet_ids         # Place nodes in private subnets for security

  # Configure auto-scaling for nodes
  scaling_config {
    desired_size = 2 # Normal running nodes
    max_size     = 3 # Maximum during high load
    min_size     = 1 # Minimum to maintain
  }

  # Use launch template for node configuration
  launch_template {
    version = aws_launch_template.eks_nodes.latest_version
    name    = aws_launch_template.eks_nodes.name
  }

  instance_types = ["t3.medium"] # AWS instance type for nodes

  # Ensure required policies and cluster exist
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_eks_cluster.ce7_grp_2_eks
  ]

  tags = {
    "Name" = "${var.name_prefix}-node"
  }
}

resource "aws_launch_template" "eks_nodes" {
  name = "${var.name_prefix}-node-template"

  vpc_security_group_ids = [aws_security_group.eks_cluster_sg.id]

  tags = {
    "Name"                                                        = "${var.name_prefix}-node"
    "kubernetes.io/cluster/${aws_eks_cluster.ce7_grp_2_eks.name}" = "owned"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                                          = "${var.name_prefix}-node"
      "kubernetes.io/cluster/${aws_eks_cluster.ce7_grp_2_eks.name}" = "owned"
    }
  }

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
/etc/eks/bootstrap.sh ${aws_eks_cluster.ce7_grp_2_eks.name}

--==BOUNDARY==--
EOF
  )
}

# This file creates and manages our EKS (Kubernetes) cluster in AWS:
#
# 1. Creates the main EKS cluster
#    - Runs Kubernetes version 1.31
#    - Can be accessed from both inside VPC and internet
#    - Uses security groups to control network access
#
# 2. Sets up worker nodes (EC2 instances) to run our applications
#    - Uses t3.medium instances in private subnets
#    - Can scale between 1-3 nodes (normally runs 2)
#    - Uses launch template for consistent node setup
#
# 3. Launch template configures how new nodes are created
#    - Sets up required security groups
#    - Adds proper Kubernetes tags
#    - Includes bootstrap script to join cluster