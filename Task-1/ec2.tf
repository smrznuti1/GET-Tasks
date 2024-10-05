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

