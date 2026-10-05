terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Lab-VPC"
  }
}

# Subnet Pública
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-1"
  }
}

# Subnet Pública 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-2"
  }
}

# Subnet Privada
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Private-Subnet-1"
  }
}

# Subnet Privada 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Private-Subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Lab-IGW"
  }
}

# Elastic IP para NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-EIP"
  }

  depends_on = [aws_internet_gateway.lab_igw]
}

# NAT Gateway en subnet pública
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "Lab-NAT"
  }

  depends_on = [aws_internet_gateway.lab_igw]
}

# Tabla de rutas pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Tabla de rutas privada
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

# Asociación de subnets públicas con tabla de rutas pública
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Asociación de subnets privadas con tabla de rutas privada
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# ==========================================
# SECURITY GROUPS
# ==========================================

# Security Group para instancias web en subnets públicas
resource "aws_security_group" "public_web_sg" {
  name        = "public-web-sg"
  description = "Security group for public web servers"
  vpc_id      = aws_vpc.lab_vpc.id

  # Permite SSH desde cualquier lugar (puede ser restringido)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from anywhere"
  }

  # Permite HTTP desde cualquier lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # Permite HTTPS desde cualquier lugar
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "Public-Web-SG"
  }
}

# Security Group para instancias de base de datos en subnets privadas
resource "aws_security_group" "private_db_sg" {
  name        = "private-db-sg"
  description = "Security group for private database servers"
  vpc_id      = aws_vpc.lab_vpc.id

  # Permite acceso MySQL/Aurora desde instancias web
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_web_sg.id]
    description     = "MySQL from web servers"
  }

  # Permite acceso PostgreSQL desde instancias web
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.public_web_sg.id]
    description     = "PostgreSQL from web servers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "Private-DB-SG"
  }
}

# Security Group para instancias de aplicación en subnets privadas
resource "aws_security_group" "private_app_sg" {
  name        = "private-app-sg"
  description = "Security group for private application servers"
  vpc_id      = aws_vpc.lab_vpc.id

  # Permite acceso de web servers
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.public_web_sg.id]
    description     = "App port from web servers"
  }

  # Permite comunicación interna entre app servers
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
    description = "Internal app communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "Private-App-SG"
  }
}

# ==========================================
# EC2 INSTANCES
# ==========================================

# Instancia web pública 1
resource "aws_instance" "web_server_1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.public_web_sg.id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data_web.sh", {
    instance_name = "web-server-1"
  }))

  tags = {
    Name = "Web-Server-1"
  }
}

# Instancia web pública 2
resource "aws_instance" "web_server_2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.public_web_sg.id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data_web.sh", {
    instance_name = "web-server-2"
  }))

  tags = {
    Name = "Web-Server-2"
  }
}

# Instancia de aplicación privada 1
resource "aws_instance" "app_server_1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.private_app_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data_app.sh", {
    instance_name = "app-server-1"
  }))

  tags = {
    Name = "App-Server-1"
  }
}

# Instancia de aplicación privada 2
resource "aws_instance" "app_server_2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.private_app_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data_app.sh", {
    instance_name = "app-server-2"
  }))

  tags = {
    Name = "App-Server-2"
  }
}

# Instancia de base de datos privada 1
resource "aws_instance" "db_server_1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.private_db_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data_db.sh", {
    instance_name = "db-server-1"
  }))

  tags = {
    Name = "DB-Server-1"
  }
}

# ==========================================
# DATA SOURCES
# ==========================================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
