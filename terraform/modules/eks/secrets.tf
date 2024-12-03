# # Create a Kubernetes secret for GHCR authentication
# resource "kubernetes_secret" "ghcr_auth" {
#   metadata {
#     name      = "${var.name_prefix}-ghcr-auth"
#     namespace = kubernetes_namespace.dev.metadata[0].name
#   }

#   type = "kubernetes.io/dockerconfigjson"

#   data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "ghcr.io" = {
#           username = "lann87"
#           password = var.github_token
#           auth     = base64encode("lann87:${var.github_token}")
#           email    = "alanpeh87@gmail.com"
#         }
#       }
#     })
#   }
#   depends_on = [time_sleep.wait_for_kubernetes]
# }