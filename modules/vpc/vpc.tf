# VPC and Internet Gateway Configuration - Sets up the primary networking infrastructure

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ce7_g2_main_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "ce7_g2_igw"
  }
}

data "aws_vpc" "main_vpc" {
  # Retrieves the details of the created VPC using its ID
  id = aws_vpc.main_vpc.id
}

