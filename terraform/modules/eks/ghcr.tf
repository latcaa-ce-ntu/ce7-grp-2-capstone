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
          username = "lann87"
          password = var.github_token
          auth     = base64encode("lann87:${var.github_token}")
          email    = "alanpeh87@gmail.com"
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

          env {
            name  = "FLASK_APP"
            value = "jokes_app.py"
          }
          env {
            name  = "FLASK_RUN_HOST"
            value = "0.0.0.0"
          }

          port {
            container_port = 5000
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 5000
            }
            initial_delay_seconds = 45
            period_seconds        = 10
            failure_threshold     = 3
            timeout_seconds       = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 5000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            failure_threshold     = 3
            timeout_seconds       = 3
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
  }

  depends_on = [
    aws_eks_node_group.ce7_grp_2_node_group,
    kubernetes_namespace.apps
  ]
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
      port        = 80   # Port the service listens on
      target_port = 5000 # Port your container exposes
    }

    type = "LoadBalancer" # This allows external access via Load Balancer
  }
}