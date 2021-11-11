//  values in the variables can be changed either by
//      1. as an argument to switch -var or -var-file
//      2. Environment Variables TF_VAR_<variable name>
// types: string, number, bool, list(type), map, set, object, tuple, any
variable "webserver_port" {
  default     = 8080 
  description = "port used for the webserver"
  type        = number
} 

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the s3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in s3"
  type = string
}

variable "instance_type" {
  description = "The type of ec2 instance to run"
  type = string
}

variable "min_size" {
  description = "The minimum number of ec2 instance in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of ec2 instance in the ASG"
  type = number
}

variable "tf_remote_state_profile" {
  description = "the profile to be used when retrieving the remote state "
  type = string
}