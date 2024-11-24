# Creates a security group that allows us to create 
# ingress rules allowing traffic for HTTP, HTTPS and SSH protocols from anywhere
resource "aws_security_group" "sg-allow-ssh-http-https" {
  name        = "${var.name_prefix}-sg-allow-ssh-http-https-${terraform.workspace}"
  description = "Allow ssh, http and https traffic to the vpc"
  vpc_id      = module.vpc.vpc_id # var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows incoming SSH traffic (TCP port 22) from any IPv4 address on the internet."
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows incoming HTTP traffic (TCP port 80) from any IPv4 address on the internet."
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows incoming HTTPS traffic (TCP port 443) from any IPv4 address on the internet."
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allows unrestricted outbound traffic from the associated resource to any destination on the internet, using any protocol and port."
  }
  #checkov:skip=CKV_AWS_260:Ensure no security groups allow ingress from 0.0.0.0:0 to port 80
  #checkov:skip=CKV_AWS_24:Ensure no security groups allow ingress from 0.0.0.0:0 to port 22
  #checkov:skip=CKV2_AWS_5:Ensure that Security Groups are attached to another resource
}

# Uses an existing security group, filtered by sg_name in variables.tf
# data "aws_security_group" "selected_security_group" {
#  filter {
#    name   = "tag:Name"
#    values = [var.sg_name]
#  }
#}