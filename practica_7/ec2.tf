resource "aws_instance" "public_instance" {
  ami           = "ami-0332d564d76dbd8d6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_virginia.id
  key_name      = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
}