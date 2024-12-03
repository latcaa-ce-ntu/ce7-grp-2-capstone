data "aws_caller_identity" "current" {}

# Create namespace to organize our applications
resource "time_sleep" "wait_for_kubernetes" {
  depends_on      = [aws_eks_cluster.ce7_grp_2_eks]
  create_duration = "20s" # Pause to ensure cluster is stable
}

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