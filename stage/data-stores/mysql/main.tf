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

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "mysql-master-password-stage"
}

resource "aws_db_instance" "db_example" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin_dev"
  password          = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string).value
}
