# resource "aws_instance" "public_instance" {
#   ami           = var.ec2_specs.ami
#   instance_type = var.ec2_specs.instance_type
#   key_name      = var.ec2_specs.key_name
#   subnet_id     = aws_subnet.public_subnet_virginia.id
#   vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
#   user_data = file("script.sh")

#   provisioner "local-exec" {
#     command = "echo ${self.public_ip} > public_instance_ip.txt"
#   }

#   # provisioner "remote-exec" {
#   #   inline = [
#   #     "echo 'Hello, World!' > /home/ec2-user/hello.txt"
#   #   ]

#   #   connection {
#   #     type        = "ssh"
#   #     user        = "ec2-user"
#   #     private_key = file("mykey.pem")
#   #     host        = self.public_ip
#   #   }
#   # }

# }

resource "aws_instance" "mywebserver" {

  ami                                  = "ami-0354c98ae10b02961"
  instance_type                        = "t2.micro"
  key_name                             = "mykey"

  subnet_id                            = aws_subnet.public_subnet_virginia.id
  tags = {
    "Name" = "Myserver"
  }
  vpc_security_group_ids = [
    aws_security_group.public_instance_sg.id
  ]
}