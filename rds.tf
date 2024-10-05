resource "aws_db_parameter_group" "custom_db_parameter_group" {
  name   = "custom-db-parameter-group"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
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
