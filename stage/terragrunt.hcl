locals {
  environment = "stage"
  aws_profile = "admin-dev"
}

remote_state {
  backend = "s3"
  config = {
    bucket          = "admin-dev-tf-state"
    key             = "stage/${path_relative_to_include()}/terraform.tfstate"
    region          = "ap-southeast-2"
    dynamodb_table  = "terraform-up-and-running-locks"
    encrypt         = true
    profile         = "admin-dev"
  }
}
