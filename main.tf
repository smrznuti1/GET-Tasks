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

resource "aws_vpc" "custom_vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "Custom VPC"
  }
}

resource "aws_subnet" "custom_subnet" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Custom Subnet"
  }
}

resource "aws_internet_gateway" "customInternetGateway" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "Custom Internet Gateway"
  }
}

resource "aws_eip" "customEIP" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.7"
  depends_on                = [aws_internet_gateway.customInternetGateway]
}

resource "aws_nat_gateway" "customNatGateway" {
  allocation_id = aws_eip.customEIP.id
  subnet_id     = aws_subnet.custom_subnet.id
  tags = {
    Name = "Custom Nat Gateway"
  }
  depends_on = [aws_eip.customEIP]
}

resource "aws_route_table" "customRouteTable" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "Custom Route Table"
  }
}

resource "aws_route" "customRoute" {
  route_table_id         = aws_route_table.customRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.customInternetGateway.id
}

resource "aws_route_table_association" "customRouteTableAssociation" {
  subnet_id      = aws_subnet.custom_subnet.id
  route_table_id = aws_route_table.customRouteTable.id
}

resource "aws_security_group" "custom_security_group" {
  vpc_id = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Custom Security Group"
  }
}

resource "aws_instance" "MyEC2Instance" {
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.custom_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.custom_security_group.id]
  tags = {
    Name = "MyEC2Instance"
  }
}
