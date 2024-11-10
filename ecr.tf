# Create an Elastic Container Registry (ECR) repository to store Docker images
resource "aws_ecr_repository" "ce7-g2-webapp" {
  name = var.ecr-repo-name

  # Allowing/Disallow image tags to be overwritten
  image_tag_mutability = "MUTABLE"

  # Image scanning configuration to automatically scan images for vulnerabilities when they are pushed
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr-repo-name
  }
}

# Data source to retrieve the details of the ECR repository created above
data "aws_ecr_repository" "ce7-g2-webapp-data" {
  name = aws_ecr_repository.ce7-g2-webapp.name
}
