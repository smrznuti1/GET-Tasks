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
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Custom Subnet"
  }
}

resource "aws_subnet" "custom_subnet2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Custom Subnet 2"
  }
}

resource "aws_db_subnet_group" "custom_db_subnet_group" {
  name       = "custom_db_subnet_group"
  subnet_ids = [aws_subnet.custom_subnet.id, aws_subnet.custom_subnet2.id]
  tags = {
    Name = "Custom DB Subnet Group"
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
    Name        = "test-ec2"
    Description = "Test instance"
    CostCenter  = "12345"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y postgresql-client
              EOF
}

resource "aws_db_parameter_group" "custom_db_parameter_group" {
  name   = "custom-db-parameter-group"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_security_group" "custom_security_group_rds" {
  name   = "rds_security_group"
  vpc_id = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_db_instance" "custom_db_instance" {
  identifier             = "custom-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.10"
  name                   = "customdb"
  username               = "cUser"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.custom_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.custom_security_group_rds.id]
  parameter_group_name   = aws_db_parameter_group.custom_db_parameter_group.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

variable "db_password" {
  type    = string
  default = "Password123"
}

output "custom_db_instance_address" {
  value       = aws_db_instance.custom_db_instance.address
  description = "The address of the custom DB instance"
}

output "custom_db_instance_port" {
  value       = aws_db_instance.custom_db_instance.port
  description = "The port of the custom DB instance"
}

output "custom_db_instance_username" {
  value       = aws_db_instance.custom_db_instance.username
  description = "The username of the custom DB instance"
}
