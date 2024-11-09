# Create an Elastic Container Registry (ECR) repository to store Docker images
resource "aws_ecr_repository" "nov4_ecs_ecr" {
  name = var.ecr_repo_name

  # Allowing/Disallow image tags to be overwritten
  image_tag_mutability = "MUTABLE"

  # Image scanning configuration to automatically scan images for vulnerabilities when they are pushed
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repo_name
  }
}

# Data source to retrieve the details of the ECR repository created above
data "aws_ecr_repository" "nov4_ecr_repo_data" {
  name = aws_ecr_repository.nov4_ecs_ecr.name
}
