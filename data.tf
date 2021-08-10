// data source represents a piece of read-only information that is fetched from the provider (aws in our case)
// every time terraform is run
// data taht can be queried include vpc, subnet, ami ids, ip address ranges, current user identity etc
data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}