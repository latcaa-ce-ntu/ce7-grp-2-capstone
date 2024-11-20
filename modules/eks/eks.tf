# Define the main EKS cluster resource
resource "aws_eks_cluster" "ce7_grp_2_eks" {
  name = "ce7-grp-2-eks-cluster"  # Name in AWS Console and kubectl
  role_arn = aws_iam_role.eks_cluster_role.arn  # This role allows EKS to create and manage resources like load balancers and EC2 instances
  version = "1.31"

  # Configure the networking settings for the EKS cluster
  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = true # Allow access to the Kubernetes API server from within the VPC
    endpoint_public_access = true # Allow access to the Kubernetes API server from the internet
    security_group_ids = [aws_security_group.eks_cluster_sg.id] # These security groups define inbound and outbound traffic rules
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy  # This prevents race conditions where the cluster might try to use the role before it's ready
  ]
}

# Define the main Fargate profile for running pods
resource "aws_eks_fargate_profile" "ce7_grp_2_fargate" {
  cluster_name = aws_eks_cluster.ce7_grp_2_eks.name  # Associate this Fargate profile with our EKS cluster
  fargate_profile_name = "ce7-grp-2-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn  # Specify the IAM role that Fargate pods will use to access AWS services
  subnet_ids = var.private_subnet_ids  # Specify which subnets Fargate pods can run in (usually private subnets)

  selector {
    namespace = "default"  # Define pod selection rules for the default namespace
  }

  selector {
    namespace = "kube-system"  # Define pod selection rules for the kube-system namespace
  }
}

# Define a specific Fargate profile for CoreDNS components
resource "aws_eks_fargate_profile" "coredns" {
  cluster_name           = aws_eks_cluster.ce7_grp_2_eks.name
  fargate_profile_name   = "coredns"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "kube-system"  # Specific selector for CoreDNS pods in kube-system namespace

    labels = {
      "k8s-app" = "kube-dns"    # Match pods with the label k8s-app=kube-dns (CoreDNS pods)
    }
  }
}

# # #EKS Self-managed via EC2
# resource "aws_eks_node_group" "ce7_grp_2_node_group" {
#   cluster_name    = aws_eks_cluster.ce7_grp_2_eks.name
#   node_group_name = "ce7-grp-2-node-group"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = var.subnet_ids

#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 1
#   }

#   instance_types = ["t3.medium"]

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_node_policy,
#     aws_iam_role_policy_attachment.eks_cni_policy,
#     aws_iam_role_policy_attachment.eks_container_registry
#   ]
# }
