data "aws_caller_identity" "current" {}

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
    name      = "${var.name_prefix}-my-application"
    namespace = kubernetes_namespace.apps.metadata[0].name
    labels = {
      app = "${var.name_prefix}-my-application"
    }
  }

  spec {
    replicas = 2 # Number of pod replicas to maintain

    selector {
      match_labels = {
        app = "${var.name_prefix}-my-application"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.name_prefix}-my-application"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.ghcr_auth.metadata[0].name
        }

        container {
          name  = "${var.name_prefix}-my-app"
          image = "ghcr.io/latcaa-ce-ntu/ce7-grp-2-the-great-laugh:d17909ad49a1692873e796c4e89e3063ea24061d.2"

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

resource "kubernetes_service" "application" {
  metadata {
    name      = "${var.name_prefix}-my-application"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }

  spec {
    selector = {
      app = "${var.name_prefix}-my-application" # This matches your deployment labels
    }

    port {
      port        = 80 # Port the service listens on
      target_port = 80 # Port your container exposes
    }

    type = "NodePort" # This allows external access via node ports
  }
}