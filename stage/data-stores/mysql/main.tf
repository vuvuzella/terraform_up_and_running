provider "aws" {
  profile = "admin-dev"
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket          = "admin-dev-tf-state"
    key             = "stage/data-stores/mysql/terraform.tfstate"
    region          = "ap-southeast-2"
    dynamodb_table  = "terraform-up-and-running-locks"
    encrypt         = true
    profile         = "admin-dev"
  }
}

module "sql_db" {
  source = "git@github.com:vuvuzella/tur_module_global_infra.git//data-stores/mysql?ref=v0.0.2"
  db_name = "example_database"
  db_password_secrets_id = "mysql-master-password-stage"
}
