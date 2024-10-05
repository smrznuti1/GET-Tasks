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
