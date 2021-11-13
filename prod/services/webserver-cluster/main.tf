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

// TODO: refactor this to be configurable in the module, ch. 5
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale_out_during_business_hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"  // occurr every 0th minute, 9th hour, every day, every month, every year
  autoscaling_group_name = module.webserver_cluster.asg_name // retrieved from the webserver_cluster's outputs
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale_in_at_night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"  // occurr every 0th minute, 17th hour, every day, every month, every year
  autoscaling_group_name = module.webserver_cluster.asg_name // retrieved from the webserver_cluster's outputs
}

module "webserver_cluster" {
  source                  = "../../../modules/services/webserver-cluster"
  cluster_name            = "webserver-${local.environment}"
  db_remote_state_bucket  = "admin-dev-tf-state"
  db_remote_state_key     = "${local.environment}/data-stores/mysql/terraform.tfstate"
  instance_type           = "t2.micro"
  min_size                = 2
  max_size                = 10
  tf_remote_state_profile = local.aws_profile
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}