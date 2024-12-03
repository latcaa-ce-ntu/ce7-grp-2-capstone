data "aws_caller_identity" "current" {}

# Wait for EKS cluster to be fully ready
resource "time_sleep" "wait_for_kubernetes" {
  depends_on      = [aws_eks_cluster.ce7_grp_2_eks]
  create_duration = "20s" # Pause to ensure cluster is stable
}

# Create namespaces to organize our applications
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}

resource "kubernetes_namespace" "uat" {
  metadata {
    name = "uat"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}

# Create IAM roles that can be assumed by Kubernetes service accounts
resource "aws_iam_role" "app_role_dev" {
  name = "${var.name_prefix}-app-role-dev"

  # Trust policy allowing Kubernetes service accounts to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Use OIDC provider for secure authentication
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # Ensure only our specific service account can assume this role
          "${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:applications:${var.name_prefix}-sa-app-dev"
        }
      }
    }]
  })
}

# Create IAM roles that can be assumed by Kubernetes service accounts
resource "aws_iam_role" "app_role_uat" {
  name = "${var.name_prefix}-app-role-uat"

  # Trust policy allowing Kubernetes service accounts to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Use OIDC provider for secure authentication
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # Ensure only our specific service account can assume this role
          "${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:applications:${var.name_prefix}-sa-app-uat"
        }
      }
    }]
  })
}

# Create IAM role that can be assumed by Kubernetes service accounts
resource "aws_iam_role" "app_role_prod" {
  name = "${var.name_prefix}-app-role-prod"

  # Trust policy allowing Kubernetes service accounts to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Use OIDC provider for secure authentication
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          # Ensure only our specific service account can assume this role
          "${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:applications:${var.name_prefix}-sa-app-prod"
        }
      }
    }]
  })
}

# Create Kubernetes service account for our application
resource "kubernetes_service_account" "dev_service_account" {
  metadata {
    name      = "${var.name_prefix}-sa-app-dev"
    namespace = kubernetes_namespace.dev.metadata[0].name
    annotations = {
      # Link to IAM role for AWS permissions
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role_dev.arn
    }
  }

  # Add GitHub container registry credentials
  # image_pull_secret {
  #   name = kubernetes_secret.ghcr_auth.metadata[0].name
  # }

  depends_on = [
    kubernetes_namespace.dev,
    aws_iam_role.app_role_dev
  ]
}

# Create Kubernetes service account for our application
resource "kubernetes_service_account" "uat_service_account" {
  metadata {
    name      = "${var.name_prefix}-sa-app-uat"
    namespace = kubernetes_namespace.uat.metadata[0].name
    annotations = {
      # Link to IAM role for AWS permissions
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role_uat.arn
    }
  }

  # Add GitHub container registry credentials
  # image_pull_secret {
  #   name = kubernetes_secret.ghcr_auth.metadata[0].name
  # }

  depends_on = [
    kubernetes_namespace.uat,
    aws_iam_role.app_role_uat
  ]
}

# Create Kubernetes service account for our application
resource "kubernetes_service_account" "prod_service_account" {
  metadata {
    name      = "${var.name_prefix}-sa-app-prod"
    namespace = kubernetes_namespace.prod.metadata[0].name
    annotations = {
      # Link to IAM role for AWS permissions
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role_prod.arn
    }
  }

  # Add GitHub container registry credentials
  # image_pull_secret {
  #   name = kubernetes_secret.ghcr_auth.metadata[0].name
  # }

  depends_on = [
    kubernetes_namespace.prod,
    aws_iam_role.app_role_prod
  ]
}

# # Kubernetes Service Account and IAM Integration
# #
# # Purpose:
# # - Creates a Kubernetes namespace for our applications
# # - Sets up IAM role for Kubernetes service accounts (IRSA)
# # - Allows pods to securely access AWS services
# #
# # Components:
# # 1. Kubernetes namespace: Isolated environment for our apps
# # 2. IAM role: Defines AWS permissions
# # 3. Service Account: Links Kubernetes pods to AWS permissions
# # 4. OIDC integration: Enables secure AWS authentication