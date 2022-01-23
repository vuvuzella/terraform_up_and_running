terraform {
    backend "s3" {}
}

variable "environment" {
  type = string
  description = "The environment to use"
}

variable "db_remote_state_bucket" {
  type = string
  description = "The s3 bucket of the db"
}

variable "db_remote_state_key" {
  type = string
  description = "The remote state key of the db"
}

variable "server_text" {
  type = string
  description = "The text of the server"
}


module "helloWorld" {
  source = "git@github.com:vuvuzella/tur_module_global_infra.git//services/hello-world-app?ref=v1.0.0"

  db_remote_state_bucket  = var.db_remote_state_bucket
  db_remote_state_key     = var.db_remote_state_key
  min_size                = 2
  max_size                = 2
  environment             = var.environment
  instance_type           = "t2.micro"
  tf_remote_state_profile = "admin-dev"
  enable_autoscaling      = false

  server_text             = var.server_text
}

output "alb_dns_name" {
  value = module.helloWorld.alb_dns_name
}

output "asg_name" {
    value = module.helloWorld.asg_name
}

output "instance_security_group_id" {
  value = module.helloWorld.instance_security_group_id
}
