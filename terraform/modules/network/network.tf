# Public Subnet Configuration Block
resource "aws_subnet" "pub_subnets" {
  count                   = length(var.pub_subnet_cidrs)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.pub_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.pub_azs[count.index]

  tags = {
    Name = "${var.name_prefix}-pub-subnet-${(count.index) + 1}"
  }
}

# Public Route Table Configuration
resource "aws_route_table" "pub_RT" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    # Through the Internet Gateway
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name_prefix}-pub-routetable"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "pub_RT_assoc" {
  count          = length(aws_subnet.pub_subnets)
  subnet_id      = aws_subnet.pub_subnets[count.index].id
  route_table_id = aws_route_table.pub_RT.id
}


# Private Subnet Configuration Block
resource "aws_subnet" "pvt_subnets" {
  count             = length(var.pvt_subnet_cidrs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.pvt_subnet_cidrs[count.index]
  availability_zone = var.pvt_azs[count.index]

  tags = {
    Name = "${var.name_prefix}-pvt-subnet-${count.index + 1}"
  }
}

# Private Route Table Configuration
resource "aws_route_table" "pvt_RT" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # Through the NAT Gateway for secure internet access
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.name_prefix}-pvt-routetable"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "pvt_RT_assoc" {
  count          = length(aws_subnet.pvt_subnets)
  subnet_id      = aws_subnet.pvt_subnets[count.index].id
  route_table_id = aws_route_table.pvt_RT.id
}
