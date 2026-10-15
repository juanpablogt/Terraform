terraform {
  required_version = ">= 0.12.2"

  # backend "s3" {
  #   region         = "us-east-1"
  #   bucket         = "mnoexmple-us-east-1-prod-terraform-state"
  #   key            = "terraform.tfstate"
  #   dynamodb_table = "mnoexmple-us-east-1-prod-terraform-state-lock"
  #   encrypt        = "true"
  # }
}
