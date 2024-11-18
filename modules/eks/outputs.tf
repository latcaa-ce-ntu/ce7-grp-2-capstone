output "cluster_endpoint" {
  value = aws_eks_cluster.ce7_grp_2_eks.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.ce7_grp_2_eks.name
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.ce7_grp_2_eks.certificate_authority[0].data
}