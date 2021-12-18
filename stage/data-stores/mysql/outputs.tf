output "db_password" {
  value = jsonencode(module.sql_db.db_password)
  sensitive = true
}

output "address" {
  value = module.sql_db.address
  description = "Connect to database at this endpoint"
}

output "port" {
  value = module.sql_db.port
  description = "The port the database is listening on"
}
