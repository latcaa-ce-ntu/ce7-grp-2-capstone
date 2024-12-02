# Get current AWS account details
data "aws_caller_identity" "current" {}

# Create a Kubernetes secret for GitHub Container Registry(GHCR) authentication
# This allows Kubernetes to pull private images from GHCR
resource "kubernetes_secret" "ghcr_auth" {
  metadata {
    name      = "${var.name_prefix}-ghcr-auth"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }

  # Specify type as docker config for container registry authentication
  type = "kubernetes.io/dockerconfigjson"

  # Create docker config with GHCR credentials
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


# Define the main Kubernetes deployment for the application
resource "kubernetes_deployment" "application" {
  metadata {
    name      = "${var.name_prefix}-my-application"
    namespace = kubernetes_namespace.apps.metadata[0].name
    labels = {
      app = "${var.name_prefix}-my-application" # Label for identifying this application
    }
  }

  spec {
    replicas = 2 # Number of pod replicas to maintain

    # Define how the deployment identifies which pods to manage
    selector {
      match_labels = {
        app = "${var.name_prefix}-my-application"
      }
    }

    # Template for creating pods
    template {
      metadata {
        labels = {
          app = "${var.name_prefix}-my-application"
        }
      }

      spec {
        # Reference the GHCR authentication secret
        image_pull_secrets {
          name = kubernetes_secret.ghcr_auth.metadata[0].name
        }

        # Container configuration
        container {
          name  = "${var.name_prefix}-my-app"
          image = "ghcr.io/latcaa-ce-ntu/ce7-grp-2-the-great-laugh:d17909ad49a1692873e796c4e89e3063ea24061d.2"

          # Environment variables for Flask application
          env {
            name  = "FLASK_APP"
            value = "jokes_app.py"
          }
          env {
            name  = "FLASK_RUN_HOST"
            value = "0.0.0.0" # Allow connections from any IP
          }

          env {
            name = "FLASK_RUN_PORT"
            value = "5000"
          }

          # Expose container port
          port {
            container_port = 5000
            protocol       = "TCP"
          }

          # Resource limits and requests for the container
          resources {
            limits = {
              cpu    = "500m" # Maximum CPU usage (500 millicores)
              memory = "1Gi"  # Maximum memory usage
            }
            requests = {
              cpu    = "250m"  # Minimum CPU requirement
              memory = "512Mi" # Minimum memory requirement
            }
          }

          # Health check to determine if pod is alive
          liveness_probe {
            http_get {
              path = "/"
              port = 5000
            }
            initial_delay_seconds = 45 # Wait before first probe
            period_seconds        = 10 # Probe interval
            failure_threshold     = 3  # Failed probes before restart
            timeout_seconds       = 3  # Probe timeout
          }

          # Health check to determine if pod is ready to serve traffic
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
      app = "${var.name_prefix}-my-application"
    }

    port {
      port        = 80
      target_port = 5000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_deployment.application,
    aws_security_group.eks_cluster_sg,
    aws_security_group.lb_sg
  ]
}

# This Terraform configuration file manages the deployment of our application to EKS:
#
# 1. GHCR Authentication (kubernetes_secret "ghcr_auth")
#    - Creates Kubernetes secret for pulling images from GitHub Container Registry
#
# 2. Application Deployment (kubernetes_deployment "application")
#    - Deploys 2 replicas of our Flask application
#    - Sets resource limits and requests for each pod
#    - Configures health checks (liveness and readiness probes)
#    - Uses GHCR auth for pulling private images
#
# 3. Service Exposure (kubernetes_service "application")
#    - Exposes the application via AWS Load Balancer
#    - Routes external traffic (port 80) to container port 5000
#    - Associates with AWS security groups for network control
#
# Dependencies:
# - Requires EKS node group to be ready
# - Requires Kubernetes namespace to exist
# - Requires security groups to be configured