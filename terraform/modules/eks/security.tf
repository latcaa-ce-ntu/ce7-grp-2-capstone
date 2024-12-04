# Create security group for EKS cluster nodes
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${var.name_prefix}-eks-cluster-sg"
  vpc_id      = var.vpc_id

  # Allow all traffic within the security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-eks-cluster-sg"
  }
}

# Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
  name_prefix = "${var.name_prefix}-lb-sg"
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
    Name = "${var.name_prefix}-lb-sg"
  }
}

# Allow traffic from LB to NodePort range
resource "aws_security_group_rule" "nodeport_from_lb" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "Allow NodePort access from LB"
}

# Network Security Configuration for EKS and Load Balancer
#
# Purpose:
# - Controls network traffic to/from our EKS cluster and Load Balancer
# - Defines allowed ports, protocols, and source/destination rules
#
# Components:
# 1. EKS Security Group: Controls traffic to Kubernetes nodes
# 2. NodePort Rules: Enables Load Balancer to reach Kubernetes services
# 3. Load Balancer Security Group: Controls external access
#
# Traffic Flow:
# Internet -> Load Balancer (80) -> EKS Nodes (5000/NodePorts) -> Application Pods