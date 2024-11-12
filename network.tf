# Public Subnet Configuration
resource "aws_subnet" "pub-subnets" {
  # The count parameter allows for creating multiple public subnets
  count  = length(var.pub-subnet-cidrs)
  vpc_id = aws_vpc.main-vpc.id

  # CIDR block for the public subnet, based on the input variable
  cidr_block = var.pub-subnet-cidrs[count.index]

  # Public IP addresses assignment to subnet
  map_public_ip_on_launch = true

  # Availability zone for the subnet, selected from the input variable
  availability_zone = var.pub-azs[count.index]

  tags = {
    Name = "ce7-g2-pubsubnet-${count.index + 1}"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "pub-RT" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "ce7-g2-routetable"
  }
}

# Associating Public Subnets with the Route Table
resource "aws_route_table_association" "pub-RT-assoc" {
  count          = length(aws_subnet.pub-subnets)
  subnet_id      = aws_subnet.pub-subnets[count.index].id
  route_table_id = aws_route_table.pub-RT.id
}

# Private Subnet Configuration
resource "aws_subnet" "pvt-subnets" {
  # The count parameter allows for creating multiple private subnets
  count  = length(var.pvt-subnet-cidrs)
  vpc_id = aws_vpc.main-vpc.id

  # CIDR block for the private subnet, based on the input variable
  cidr_block = var.pvt-subnet-cidrs[count.index]

  # Availability zone for the subnet, selected from the input variable
  availability_zone = var.pvt-azs[count.index]

  # Tags to identify the private subnet
  tags = {
    Name = "ce7-g2-pvtsub-${count.index + 1}"
  }
}

# Security Group for ECS Tasks/Services
resource "aws_security_group" "ecs-sg" {
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed-ingress-cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ce7-g2-ecs-sg"
  }
}
