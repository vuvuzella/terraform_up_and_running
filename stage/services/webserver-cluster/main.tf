provider "aws" {
    profile = "admin-dev"
    region  = "ap-southeast-2"
}

// use S3 bucket and DynamoDB for terraform state store and locking
// Make sure the S3 bucket and the dynamoDB table for locking has been deployed
terraform {
  backend "s3" {
    bucket         = "admin-dev-tf-state"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
    profile        = "admin-dev"   # uncomment this if environment variable AWS_PROFILE is not set
                              # see https://stackoverflow.com/questions/55449909/error-while-configuring-terraform-s3-backend
  }
}