# EKS Cluster Security Group
# This security group controls network traffic to and from the EKS cluster's control plane and worker nodes
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "ce7-grp-2-eks-cluster-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ce7_grp_2_eks_cluster_sg"
  }
}

# Load Balancer Security Group
# This security group controls traffic to and from the Application Load Balancer (ALB)
# While similar to the EKS cluster SG, it serves a different purpose in the architecture
resource "aws_security_group" "lb_sg" {
  name_prefix = "ce7-grp-2-lb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}