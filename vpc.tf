# VPC and Internet Gateway Configuration - Sets up the primary networking infrastructure

resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ce7-g2-main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "ce7-g2-igw"
  }
}

data "aws_vpc" "main-vpc" {
  # Retrieves the details of the created VPC using its ID
  id = aws_vpc.main-vpc.id
}
