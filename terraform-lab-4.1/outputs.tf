output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.lab_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.lab_vpc.cidr_block
}

output "public_subnet_1_id" {
  description = "ID of public subnet 1"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "ID of public subnet 2"
  value       = aws_subnet.public_subnet_2.id
}

output "private_subnet_1_id" {
  description = "ID of private subnet 1"
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "ID of private subnet 2"
  value       = aws_subnet.private_subnet_2.id
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.public_web_sg.id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.private_app_sg.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.private_db_sg.id
}

output "web_server_1_public_ip" {
  description = "Public IP of web server 1"
  value       = aws_instance.web_server_1.public_ip
}

output "web_server_2_public_ip" {
  description = "Public IP of web server 2"
  value       = aws_instance.web_server_2.public_ip
}

output "web_server_1_private_ip" {
  description = "Private IP of web server 1"
  value       = aws_instance.web_server_1.private_ip
}

output "web_server_2_private_ip" {
  description = "Private IP of web server 2"
  value       = aws_instance.web_server_2.private_ip
}

output "app_server_1_private_ip" {
  description = "Private IP of app server 1"
  value       = aws_instance.app_server_1.private_ip
}

output "app_server_2_private_ip" {
  description = "Private IP of app server 2"
  value       = aws_instance.app_server_2.private_ip
}

output "db_server_1_private_ip" {
  description = "Private IP of database server 1"
  value       = aws_instance.db_server_1.private_ip
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}
