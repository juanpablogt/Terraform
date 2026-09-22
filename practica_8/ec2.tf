variable "instancias" {
  description = "Nombre de las instancias"
  type        = list(string)
  default     = ["apache","mysql","jumpserver"]
}
resource "aws_instance" "public_instance" {
  for_each      = toset(var.instancias)
  ami           = var.ec2_specs.ami
  instance_type = var.ec2_specs.instance_type
  key_name      = var.ec2_specs.key_name
  subnet_id     = aws_subnet.public_subnet_virginia.id
  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
  user_data = file("script.sh")
  monitoring = var.enabled_monitoring
  tags = {
    Name = each.value
  }
}

resource "aws_instance" "monitoring_instance" {
  count         = var.enabled_monitoring ? 1 : 0
  ami           = var.ec2_specs.ami
  instance_type = var.ec2_specs.instance_type
  key_name      = var.ec2_specs.key_name
  subnet_id     = aws_subnet.public_subnet_virginia.id
  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
  user_data = file("script.sh")

  tags = {
    Name = "monitoreo"  
  }
}
