output "db_password" {
  value = jsonencode(data.aws_secretsmanager_secret_version.db_password.secret_string)
  sensitive = true
}

output "address" {
  value = aws_db_instance.db_example.address
  description = "Connect to database at this endpoint"
}

output "port" {
  value = aws_db_instance.db_example.port
  description = "The port the database is listening on"
}