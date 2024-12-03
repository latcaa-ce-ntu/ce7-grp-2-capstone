# resource "aws_ecr_repository" "ce7_grp_2_webapp" {
#   name                 = "${var.name_prefix}-webapp"
#   image_tag_mutability = "MUTABLE"

#   # Automatically scan images for vulnerabilities when they are pushed
#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = {
#     Name = "${var.name_prefix}-webapp"
#   }
# }