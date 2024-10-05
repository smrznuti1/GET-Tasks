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
