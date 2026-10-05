#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable --now httpd
echo "Hello, hard World!" > /var/www/html/index.html

