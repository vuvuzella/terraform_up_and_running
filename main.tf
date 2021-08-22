provider "aws" {
    profile = "admin-dev"
    region = "ap-southeast-2"
}

// S3 bucket for storing and versioning the statefile
resource "aws_s3_bucket" "terraform_state" {
    bucket = "admin-dev-tf-state"
    # prevent accidentally deleting this S3 bucket
    lifecycle {
        prevent_destroy = true
    }

    # Enable versioning so we can see the full revision history of state files
    versioning {
        enabled = true
    }

    # Enable server-side encryption by default
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
    
}

// Use DynamoDB as a locking mechanism for terraform
resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

// use S3 bucket and DynamoDB for terraform state store and locking
// Make sure the S3 bucket and the dynamoDB table for locking has been deployed
terraform {
  backend "s3" {
    bucket = "admin-dev-tf-state"
    key = "global/s3/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
    # profile = "admin-dev"   # uncomment this if environment variable AWS_PROFILE is not set
                              # see https://stackoverflow.com/questions/55449909/error-while-configuring-terraform-s3-backend
  }
}