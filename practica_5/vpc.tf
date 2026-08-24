resource "aws_vpc" "VPC_virginia" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC_virginia"
    name = "prueba"
    env  = "dev"

  }
}

resource "aws_vpc" "VPC_ohio" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "VPC_ohio"
    name = "prueba"
    env  = "dev"

  }
  provider = aws.ohio
}

resource "aws_vpc" "VPC_california" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "VPC_california"
    name = "prueba"
    env  = "dev"

  }
  provider = aws.california
}