virginia_cidr = "10.10.0.0/16"
# private_subnet_cidr = "10.10.1.0/24"
# public_subnet_cidr = "10.10.2.0/24"

subnets = ["10.10.1.0/24", "10.10.2.0/24"]

tags = {
  Name = "prueba"
  env  = "dev"
  cloud = "aws"
  owner = "pablo"
  IAC = "terraform"
  IAC_version = "1.6.0"
}