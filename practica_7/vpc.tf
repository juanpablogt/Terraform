resource "aws_vpc" "VPC_virginia" {
  cidr_block = var.virginia_cidr
  tags = {
    Name = "VPC_virginia"
  }
}

resource "aws_subnet" "public_subnet_virginia" {
  vpc_id                  = aws_vpc.VPC_virginia.id
  cidr_block              = var.subnets[0]
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC_virginia.id
  tags = {
    Name = "igw vpc virginia"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.VPC_virginia.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
      Name = "Public Route Table"
    }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_virginia.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "public_instance_sg" {
  name        = "public_instance_sg"
  description = "Allow SSH and all egress traffic"
  vpc_id      = aws_vpc.VPC_virginia.id

  ingress {
    description = "SSH over Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr]
  
}
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "public_instance_sg"
  }
}