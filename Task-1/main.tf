terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.76.1"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/home/filip/.aws/credentials"
  profile                 = "default"
}

