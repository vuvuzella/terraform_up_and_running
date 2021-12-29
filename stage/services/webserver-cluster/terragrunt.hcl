terraform {
  source = "git@github.com:vuvuzella/tur_module_global_infra.git//services/webserver-cluster?ref=v0.0.31"
}

include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}

inputs = {
  cluster_name            = "webserver-${local.common_vars.locals.environment}"
  db_remote_state_bucket  = "admin-dev-tf-state"
  db_remote_state_key     = "${local.common_vars.locals.environment}/data-stores/mysql/terraform.tfstate"
  instance_type           = "t2.micro"
  min_size                = 2
  max_size                = 2
  tf_remote_state_profile = "${local.common_vars.locals.aws_profile}"
  enable_autoscaling      = true

  ami                     = "ami-0567f647e75c7bc05"
  server_text             = "New Server Text"
}
