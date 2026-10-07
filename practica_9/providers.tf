terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.61.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
  required_version = "~> 1.15.0"
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.tags
  }
}
