// This requires the database to exist first

// terraform {
//     source = "git@github.com:vuvuzella/tur_module_global_infra.git//services/hello-world-app?ref=v1.0.0"
//   // source = "${path_relative_from_include()}/../../modules/services/hello-world-app"
// }

include {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
}

inputs = {
  db_remote_state_bucket  = "admin-dev-tf-state"
  db_remote_state_key     = "${local.common_vars.locals.environment}/data-stores/mysql/terraform.tfstate"
  environment             = "stage"
  server_text             = "Hello Staging World"
}
