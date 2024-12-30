terraform {
  required_version = "~> 1.10"

  # backend "s3" {
  #   bucket = "sctp-ce7-tfstate"           # Terraform State bucket name
  #   key    = "ce7-grp-2-capstone.tfstate" # Name of your tfstate file
  #   region = "us-east-1"                  # Terraform State bucket region
  # }

  backend "s3" {
    # bucket         = "sctp-ce7-tfstate-new"
    bucket         = "sctp-ce9-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}