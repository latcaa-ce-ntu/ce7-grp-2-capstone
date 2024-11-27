resource "time_sleep" "wait_for_kubernetes" {
  depends_on = [aws_eks_cluster.ce7_grp_2_eks]
  create_duration = "20s"
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "${var.name_prefix}-applications"
  }

  depends_on = [time_sleep.wait_for_kubernetes]
}

resource "aws_iam_role" "app_role" {
  name = "${var.name_prefix}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.ce7_grp_2_eks.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:applications:${var.name_prefix}-app"
        }
      }
    }]
  })
}

resource "kubernetes_service_account" "app_service_account" {
  metadata {
    name      = "${var.name_prefix}-app"  # This matches what we used in the IAM role
    namespace = kubernetes_namespace.apps.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role.arn
    }
  }

  image_pull_secret {
    name = kubernetes_secret.ghcr_auth.metadata[0].name
  }

  depends_on = [
    kubernetes_namespace.apps,
    aws_iam_role.app_role
  ]
}
