data "aws_caller_identity" "current" {}

# # Create an AWS Secrets Manager secret to store GHCR credentials
# data "aws_secretsmanager_secret" "existing_pat" {
#   name = "${var.name_prefix}-github-pat"
#   count = 0  # This prevents error if secret doesn't exist
# }

# resource "time_sleep" "wait_for_secret_deletion" {
#   create_duration = "30s"
# }

# resource "aws_secretsmanager_secret" "github_pat" {
#   name        = "${var.name_prefix}-github-pat"
#   description = "GitHub Personal Access Token for GHCR authentication"
  
#   depends_on = [time_sleep.wait_for_secret_deletion]
# }


# resource "aws_secretsmanager_secret_version" "github_pat" {
#   secret_id     = aws_secretsmanager_secret.github_pat.id
#   secret_string = var.github_token
# }

# Create a Kubernetes secret for GHCR authentication
resource "kubernetes_secret" "ghcr_auth" {
  metadata {
    name      = "${var.name_prefix}-ghcr-auth"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth = base64encode(var.github_token)
        }
      }
    })
  }
}

resource "kubernetes_deployment" "application" {
  metadata {
    name      = "my-application"
    namespace = kubernetes_namespace.apps.metadata[0].name
    labels = {
      app = "my-application"
    }
  }

  spec {
    replicas = 2  # Number of pod replicas to maintain

    selector {
      match_labels = {
        app = "my-application"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-application"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.ghcr_auth.metadata[0].name
        }
        
        container {
          name  = "my-app"
          image = "ghcr.io/latcaa-ce-ntu/ce7-grp-2-the-great-laugh:tag"
          
          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.25"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

# # Add IAM policy to allow EKS nodes to access Secrets Manager
# resource "aws_iam_role_policy" "node_secrets_policy" {
#   name = "${var.name_prefix}-eks-node-secrets-policy"
#   role = aws_iam_role.eks_node_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#         ]
#         Resource = [aws_secretsmanager_secret.github_pat.arn]
#       }
#     ]
#   })
# }