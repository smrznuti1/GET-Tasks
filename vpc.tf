resource "aws_vpc" "custom_vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "Custom VPC"
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
