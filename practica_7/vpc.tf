resource "aws_vpc" "VPC_virginia" {
  cidr_block = var.virginia_cidr
  tags = {
    Name = "VPC_virginia"
  }
}

resource "aws_subnet" "public_subnet_virginia" {
  vpc_id     = aws_vpc.VPC_virginia.id
  cidr_block = var.subnets[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet Virginia"
  }
}

resource "aws_subnet" "private_subnet_virginia" {
  vpc_id     = aws_vpc.VPC_virginia.id
  cidr_block = var.subnets[1]
  tags = {
    Name = "Private Subnet Virginia"
  }
}