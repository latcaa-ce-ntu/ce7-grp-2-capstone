# Main VPC Configuration
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}


# Elastic IP Configuration for NAT Gateway
# Allocates a static public IP address that will be used by the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-eip"
  }
}

# NAT Gateway Configuration
# Allows private subnet resources to access the internet while remaining private
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_subnets[0].id # Attach to first public subnet

  tags = {
    Name = "${var.name_prefix}-nat-gw"
  }
}