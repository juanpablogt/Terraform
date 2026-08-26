resource "aws_vpc" "VPC_virginia" {
  cidr_block = var.virginia_cidr
  tags = {
    Name = "VPC_virginia"
    name = "prueba"
    env  = "dev"

  }
}

resource "aws_subnet" "public_subnet_virginia" {
  vpc_id     = aws_vpc.VPC_virginia.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_virginia" {
  vpc_id     = aws_vpc.VPC_virginia.id
  cidr_block = var.private_subnet_cidr
}