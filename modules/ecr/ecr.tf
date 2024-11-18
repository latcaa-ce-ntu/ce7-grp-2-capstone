# Create an Elastic Container Registry (ECR) repository to store Docker images
resource "aws_ecr_repository" "ce7_grp_2_webapp" {
  name = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  # Automatically scan images for vulnerabilities when they are pushed
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repo_name
  }
}

# Data source to retrieve the details of the ECR repository created above
data "aws_ecr_repository" "ce7_grp_2_webapp_data" {
  name = aws_ecr_repository.ce7_grp_2_webapp.name
}
