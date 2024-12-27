# ---------------------------------------------------
# Output for Jokes
# ---------------------------------------------------

# output "api-gateway-url" {
#   value = aws_api_gateway_deployment.jokes_deployment.invoke_url
# }

# ---------------------------------------------------
# Output for HCA
# ---------------------------------------------------

output "api-gateway-url" {
  value = aws_api_gateway_deployment.hca_deployment.invoke_url
}
