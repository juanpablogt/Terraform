variable "virginia_cidr" {
  description = "CIDR_Virginia"
  type        = string
}

# variable "private_subnet_cidr" {
#     description = "Private Subnet CIDR"
#     type        = string
# }

# variable "public_subnet_cidr" {
#     description = "Public Subnet CIDR"
#     type        = string
# }

variable "subnets" {
  description = "Lista de subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
}
variable "ingress_cidr" {
  description = "CIDR para reglas de ingreso"
  type        = string
}

variable "ec2_specs" {
  description = "parametros de la instancia EC2"
  type = object({
    ami           = string
    instance_type = string
    key_name      = string
  })
}