resource "aws_key_pair" "custom_key_pair" {
  key_name   = "custom-key-pair"
  public_key = file("/home/filip/.ssh/aws-ec2-key.pub")
}

resource "aws_instance" "MyEC2Instance" {
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.custom_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.custom_security_group.id]
  key_name                    = aws_key_pair.custom_key_pair.key_name
  depends_on                  = [aws_db_instance.custom_db_instance]
  tags = {
    Name        = "test-ec2"
    Description = "Test instance"
    CostCenter  = "12345"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y postgresql-client
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              PSQL="psql postgresql://${aws_db_instance.custom_db_instance.username}:${var.db_password}@${aws_db_instance.custom_db_instance.address}:5432/${aws_db_instance.custom_db_instance.name}"

              $PSQL <<SQL
              CREATE TABLE IF NOT EXISTS ${var.table_name} (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100),
                surname VARCHAR(100)
              );
              SQL

              $PSQL <<SQL
              INSERT INTO ${var.table_name} (name, surname) VALUES ('Filip', 'Bozovic');
              INSERT INTO ${var.table_name} (name, surname) VALUES ('Bilip', 'Fozovic');
              SQL
              EOF
}
