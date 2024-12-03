# Create namespace to organize our applications
resource "time_sleep" "wait_for_kubernetes" {
  depends_on      = [aws_eks_cluster.ce7_grp_2_eks]
  create_duration = "20s" # Pause to ensure cluster is stable
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "${var.name_prefix}-ns-dev"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}

resource "kubernetes_namespace" "uat" {
  metadata {
    name = "${var.name_prefix}-ns-uat"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "${var.name_prefix}-ns-prod"
  }
  depends_on = [time_sleep.wait_for_kubernetes]
}