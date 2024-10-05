terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "custom_subnet" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Custom Subnet"
  }
}

resource "aws_instance" "MyAWSResource" {
  ami           = "ami-08eb150f611ca"
  instance_type = "t2.micro"
}
