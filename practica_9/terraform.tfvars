virginia_cidr = "10.10.0.0/16"
# private_subnet_cidr = "10.10.1.0/24"
# public_subnet_cidr = "10.10.2.0/24"

subnets = ["10.10.1.0/24", "10.10.2.0/24"]


tags = {
  Name        = "prueba"
  cloud       = "aws"
  owner       = "pablo"
  IAC         = "terraform"
  IAC_version = "1.6.0"
  project     = "practica_8"
  region      = "Virginia"
  env         = "dev"
}
ingress_cidr = "0.0.0.0/0"

ec2_specs = {
  ami           = "ami-0332d564d76dbd8d6"
  instance_type = "t2.micro"
  key_name      = "mykey"
}

enabled_monitoring = false