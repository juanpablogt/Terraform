output "ec2_public_ip" {
  value = aws_instance.mywebserver.public_ip
}