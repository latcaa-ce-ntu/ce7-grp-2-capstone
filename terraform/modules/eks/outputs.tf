output "cluster_endpoint" {
  value = aws_eks_cluster.ce7_grp_2_eks.endpoint # Retrieves the HTTPS endpoint for accessing the Kubernetes API server
}

output "cluster_name" {
  value = aws_eks_cluster.ce7_grp_2_eks.name # Outputs the name of the EKS cluster for reference in other configurations
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id # Outputs the ID of the security group controlling network access to the cluster
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.ce7_grp_2_eks.certificate_authority[0].data
  # This outputs the base64-encoded certificate authority (CA) data for the EKS cluster
  # The CA data is crucial for:
  # 1. Establishing secure TLS connections to the Kubernetes API server
  # 2. Authenticating the API server's identity to prevent man-in-the-middle attacks
  # 3. Required for generating valid kubeconfig files for kubectl access
  # 4. Used by cluster components to verify API server certificates
  # The [0] index is used because certificate_authority returns a list with a single item
}