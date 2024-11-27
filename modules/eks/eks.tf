# Define the main EKS cluster resource
resource "aws_eks_cluster" "ce7_grp_2_eks" {
  name     = "ce7-grp-2-eks-cluster"           # Name in AWS Console and kubectl
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
    aws_iam_role_policy_attachment.eks_cluster_policy # This prevents race conditions where the cluster might try to use the role before it's ready
  ]
}

# EKS Self-managed via EC2
resource "aws_eks_node_group" "ce7_grp_2_node_group" {
  cluster_name    = aws_eks_cluster.ce7_grp_2_eks.name
  node_group_name = "ce7-grp-2-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn # Allows nodes permission to interact with AWS Services
  subnet_ids      = var.private_subnet_ids # Nodes are placed in Pvt Subnets

  scaling_config {
    desired_size = 2 
    max_size     = 3 # Max no. of nodes during high load
    min_size     = 1 # Min no. of nodes to maintain
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry
    # node_policy = basic nodes operations
    # cni_policy = Networking functionality
    # container_registry = Access to ECR to pull container images
  ]
}
