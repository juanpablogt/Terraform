
echo "Hello, World!" > /home/ec2-user/hello.txt
yum update -y
yum install -y httpd -y
systemctl start httpd
systemctl start apache2
