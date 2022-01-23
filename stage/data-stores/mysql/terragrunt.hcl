// Put this in terraform instead of terragrunt
// terraform {
//   source = "git@github.com:vuvuzella/tur_module_global_infra.git//data-stores/mysql?ref=v1.0.0"
// }

include {
  path = find_in_parent_folders()
}

inputs = {
  db_name                   = "example_database"
  db_password_secrets_id    = "mysql-master-password-stage"
  db_skip_final_snapshot    = true
}
