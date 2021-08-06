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
    // give ec2 instance a start script using heredoc
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p 8080 &
        EOF
    // reference the security group by using resource attribute referemce
    // <provider>_<type>.<name>.<attribute>
    // this creates an implicit dependency
    vpc_security_group_ids = [aws_security_group.instance.id]
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress = [{
      cidr_blocks = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = ["::/0"]
      description = "accept all incoming traffic from all ip addresses"
      from_port = 8080
      protocol = "tcp"
      to_port = 8080
      prefix_list_ids = []
      security_groups = []
      self = true
    } ]
}