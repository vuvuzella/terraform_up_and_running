provider "aws" {
  region = "ap-southeast-2"
}
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name = "webserver-stage"
  db_remote_state_bucket = "admin-dev-tf-state"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}