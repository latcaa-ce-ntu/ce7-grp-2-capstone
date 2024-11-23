# Create Amazon ECR repository to store Docker images
resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.name_prefix}-hello-world-ecr"
}