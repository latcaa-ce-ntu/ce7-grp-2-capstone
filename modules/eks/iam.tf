# IAM role for EKS cluster control plane
resource "aws_iam_role" "eks_cluster_role" {
   name = "ce7-grp-2-eks-cluster-role"
   
   # Trust policy allowing EKS service to assume this role
   assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
           {
               Action = "sts:AssumeRole"
               Effect = "Allow"
               Principal = {
                   Service = "eks.amazonaws.com"
               }
           }
       ]
   })
}

# Attach required EKS cluster permissions to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  # AWS managed policy for EKS clusters
   role = aws_iam_role.eks_cluster_role.name   # Attach to our cluster role
}

# IAM role for Fargate pod execution
resource "aws_iam_role" "fargate_pod_execution_role" {
   name = "ce7-grp-2-eks-fargate-role"
   
   # Trust policy allowing Fargate pods to assume this role 
   assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
           {
               Action = "sts:AssumeRole"
               Effect = "Allow"
               Principal = {
                   # Only Fargate pods can assume this role
                   Service = "eks-fargate-pods.amazonaws.com"
               }
           }
       ]
   })
}

# Attach required Fargate pod execution permissions
resource "aws_iam_role_policy_attachment" "fargate_pod_execution_policy" {
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"   # AWS managed policy for Fargate pod execution
   role = aws_iam_role.fargate_pod_execution_role.name
}
