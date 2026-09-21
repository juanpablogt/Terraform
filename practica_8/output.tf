output "ec2_public_ips" {
  value = [for i in aws_instance.public_instance : i.public_ip]
}