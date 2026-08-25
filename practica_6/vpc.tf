resource "aws_vpc" "VPC_virginia" {
  cidr_block = var.virginia_cidr
  tags = {
    Name = "VPC_virginia"
    name = "prueba"
    env  = "dev"

  }
}

resource "aws_vpc" "VPC_ohio" {
  cidr_block = var.ohio_cidr
  tags = {
    Name = "VPC_ohio"
    name = "prueba"
    env  = "dev"

  }
  provider = aws.ohio
}

resource "aws_vpc" "VPC_california" {
  cidr_block = var.california_cidr
  tags = {
    Name = "VPC_california"
    name = "prueba"
    env  = "dev"

  }
  provider = aws.california
}