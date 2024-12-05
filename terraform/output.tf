output "api-gateway-url" {
  value = aws_api_gateway_deployment.jokes_deployment.invoke_url
}

# output "api_gateway_execution_arn" {
#   value = aws_api_gateway_rest_api.jokes_api.execution_arn
# }
