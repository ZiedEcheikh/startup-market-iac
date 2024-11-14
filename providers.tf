terraform {
  required_version = ">=1.9.0"
  backend "s3" {
    bucket = "startup-market-dev"
    key    = "market-iac-state-dev/terraform.tfstate"
    region = "eu-west-3"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.region
  default_tags {
    tags = {
      BuiltBy     = "Zied-Startup"
      ManagedByTF = true
    }
  }
}
