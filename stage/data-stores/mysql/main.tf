terraform {
  backend "s3" {}
}

variable "db_name" {
  type = string
}

variable "db_password_secrets_id" {
  type = string
}

module "mysqldb" {
  source = "git@github.com:vuvuzella/tur_module_global_infra.git//data-stores/mysql?ref=v1.0.0"

  db_name = var.db_name
  db_password_secrets_id = var.db_password_secrets_id
}

output "address" {
  value = module.mysqldb.address
}

output "port" {
  value = module.mysqldb.port
}
