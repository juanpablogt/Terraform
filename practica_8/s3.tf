resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-${local.s3-sufix}"
}