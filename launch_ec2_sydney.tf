// Individual EC2 instance
// resource "aws_instance" "example" {
//     /*
//     ubuntu Server 20.04 LTS (HVM),
//     EBS General Purpose (SSD) Volume Type.
//     Support available from Canonical
//     */
//     ami = "ami-0567f647e75c7bc05"
//     instance_type = "t2.micro"
//     tags = {
//         Name = "example"
//     }
//     // give ec2 instance a start script using heredoc
//     // use ${...} interpolation to inline scripts to parametarize the same stuff
//     user_data = <<-EOF
//         #!/bin/bash
//         echo "Hello, World" > index.html
//         nohup busybox httpd -f -p ${var.webserver_port} &
//         EOF
//     // reference the security group by using resource attribute referemce
//     // <provider>_<type>.<name>.<attribute>
//     // this creates an implicit dependency
//     vpc_security_group_ids = [aws_security_group.ec2instance_example_sg.id]
// }

// configure auto scaling group
resource "aws_launch_configuration" "example" {
    image_id = "ami-0567f647e75c7bc05"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.ec2instance_example_sg.id]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p ${var.webserver_port} &
        EOF
    // create_before destroy is required when using a launch config with auto scaling group
    // https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids
    min_size = 2
    max_size = 10
    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

resource "aws_security_group" "ec2instance_example_sg" {
    name = "ec2instance_example_sg"
    ingress = [{
      cidr_blocks = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = ["::/0"]
      description = "accept all incoming traffic from all ip addresses"
      from_port = var.webserver_port
      protocol = "tcp"
      to_port = var.webserver_port
      prefix_list_ids = []
      security_groups = []
      self = true
    } ]
}
