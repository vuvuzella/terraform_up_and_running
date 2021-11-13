locals {
  aws_profile = "admin-dev"
  environment = "prod"
}

provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket         = "admin-dev-tf-state"
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
    profile        = "admin-dev"   # uncomment this if environment variable AWS_PROFILE is not set
                              # see https://stackoverflow.com/questions/55449909/error-while-configuring-terraform-s3-backend
  }
}

module "webserver_cluster" {
  source = "../../modules/services/webserver-cluster"
  cluster_name            = "webserver-${local.environment}"
  db_remote_state_bucket  = "admin-dev-tf-state"
  db_remote_state_key     = "${local.environment}/data-stores/mysql/terraform.tfstate"
  instance_type           = "t2.micro"
  min_size                = 2
  max_size                = 10
  tf_remote_state_profile = local.aws_profile
}