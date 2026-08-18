resource "aws_s3_bucket" "bucket1" {
  count  = 8
  bucket = "bucket1-practica4mnodx${random_string.sufijo[count.index].id}"

  tags = {
    owner = "Juan Pablo"
    environment = "dev"
    office = "Bogotá"
  }
}

resource "random_string" "sufijo" {
  count  = 8
  length = 6
  special = false
  upper = false
  numeric = true
}