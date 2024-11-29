# Define the main EKS cluster resource
resource "aws_eks_cluster" "ce7_grp_2_eks" {
  name     = "${var.name_prefix}-eks-cluster"  # Name in AWS Console and kubectl
  role_arn = aws_iam_role.eks_cluster_role.arn # This role allows EKS to create and manage resources like load balancers and EC2 instances
  version  = "1.31"

  # Configure the networking settings for the EKS cluster
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true                                   # Allow access to the Kubernetes API server from within the VPC
    endpoint_public_access  = true                                   # Allow access to the Kubernetes API server from the internet
    security_group_ids      = [aws_security_group.eks_cluster_sg.id] # These security groups define inbound and outbound traffic rules
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy, # This prevents race conditions where the cluster might try to use the role before it's ready
    aws_security_group.eks_cluster_sg
  ]
}

# EKS Self-managed via EC2
resource "aws_eks_node_group" "ce7_grp_2_node_group" {
  cluster_name    = aws_eks_cluster.ce7_grp_2_eks.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn # Allows nodes permission to interact with AWS Services
  subnet_ids      = var.private_subnet_ids         # Nodes are placed in Pvt Subnets

  scaling_config {
    desired_size = 2
    max_size     = 3 # Max no. of nodes during high load
    min_size     = 1 # Min no. of nodes to maintain
  }

  launch_template {
    version = aws_launch_template.eks_nodes.latest_version
    name    = aws_launch_template.eks_nodes.name
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    # node_policy = basic nodes operations
    # cni_policy = Networking functionality
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