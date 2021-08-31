// data source represents a piece of read-only information that is fetched from the provider (aws in our case)
// every time terraform is run
// data that can be queried include vpc, subnet, ami ids, ip address ranges, current user identity etc
// config is a search parameter
data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default_sg" {
  name = "default"
}