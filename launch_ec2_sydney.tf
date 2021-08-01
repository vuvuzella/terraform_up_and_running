resource "aws_instance" "example-terraform" {
    /*
    ubuntu Server 20.04 LTS (HVM),
    EBS General Purpose (SSD) Volume Type.
    Support available from Canonical
    */
    ami = "ami-0567f647e75c7bc05"
    instance_type = "t2.micro"
    tags = {
        Name = "terraform-example"
    }
}