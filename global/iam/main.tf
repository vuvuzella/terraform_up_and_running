provider "aws" {
  // Need to explicitly set the profile and region if the AWS_PROFILE and AWS_REGION environment variables are not set
    profile = "admin-dev"
    region  = "ap-southeast-2"
}

locals {
  user_names = ["jon1", "jon2", "jon3"]
}

resource "aws_iam_user" "global_users" {
  for_each = toset(local.user_names)
  name = each.value
}

terraform {
  backend "s3" {
    bucket          = "admin-dev-tf-state"
    key             = "global/iam/terraform.tfstate"
    region          = "ap-southeast-2"
    dynamodb_table  = "terraform-up-and-running-locks"
    encrypt         = true
    profile         = "admin-dev"   # uncomment this if environment variable AWS_PROFILE is not set
                                    # see https://stackoverflow.com/questions/55449909/error-while-configuring-terraform-s3-backend
  }
}