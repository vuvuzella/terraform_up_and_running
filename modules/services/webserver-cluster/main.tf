locals {
  http_port     = 80
  any_port      = 0
  any_protocol  = "-1"
  tcp_protocol  = "tcp"
  all_ipv4      = ["0.0.0.0/0"]
  all_ipv6      = ["::/0"]
}

// Read data-store/mysql's output data
// this is read-only.
// Uncomment this when mysql module has been deployed
data "terraform_remote_state" "db" {
    backend = "s3"
    config = {
      bucket    = var.db_remote_state_bucket
      key       = var.db_remote_state_key
      region    = "ap-southeast-2"
      profile   = var.tf_remote_state_profile
     }
}

data "template_file" "user_data" {
    template = file("${path.module}/user-data.sh")
    vars = {
      "server_port" = var.webserver_port,
      "db_address"  = data.terraform_remote_state.db.outputs.address
      "db_port"     = data.terraform_remote_state.db.outputs.port
    }
}

resource "aws_security_group" "ec2instance_example_sg" {
    name = "${var.cluster_name}-instance"
    ingress = [{
        cidr_blocks         = local.all_ipv4
        ipv6_cidr_blocks    = local.all_ipv6
        description         = "accept all incoming traffic from all ip addresses"
        from_port           = var.webserver_port
        protocol            = "tcp"
        to_port             = var.webserver_port
        prefix_list_ids     = []
        security_groups     = []
        self                = true  // whether the security group itself will be added as source to the ingress/egress rule
    }]
}

// configure auto scaling group
resource "aws_launch_configuration" "example" {
    image_id        = "ami-0567f647e75c7bc05"
    instance_type   = var.instance_type
    security_groups = [aws_security_group.ec2instance_example_sg.id]
    user_data       = data.template_file.user_data.rendered

    // create_before destroy is required when using a launch config with auto scaling group
    // https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
    lifecycle {
        create_before_destroy = true
    }
}

resource aws_launch_template "example" {
    instance_type = var.instance_type
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier  = data.aws_subnet_ids.default.ids

    // take advantage of first-class integration between ASG and ALB
    target_group_arns = [ aws_lb_target_group.asg.arn ]
    health_check_type = "ELB"   // default is EC2. 

    // instance_type   = var.instance_type
    min_size        = var.min_size
    max_size        = var.max_size

    launch_template {
        id = aws_launch_template.example.id
    }

    tag {
        key                 = "Name"
        value               = "${var.cluster_name}-example"
        propagate_at_launch = true
    }
}

resource "aws_lb" "example" {
    // name = "terraform-asg-example"
    name                = "${var.cluster_name}-aws-alb"
    load_balancer_type  = "application"
    subnets             = data.aws_subnet_ids.default.ids
    security_groups     = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn   = aws_lb.example.arn
    port                = local.http_port
    protocol            = "HTTP"

    // by default, return a simple 404 page
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type    = "text/plain"
            message_body    = "404: page not found"
            status_code     = 404
        }
    }
}

resource "aws_security_group" "alb" {
    name = "${var.cluster_name}-alb"

    # Allow inbound http requests
    ingress {
      cidr_blocks   = local.all_ipv4
      description   = "ingress for application load balancer"
      from_port     = local.http_port
      protocol      = "tcp"
      to_port       = local.http_port
      // ipv6_cidr_blocks = [ "::/0" ]
      // prefix_list_ids = []
      // security_groups = []
      // self = false
    }

    # Allow all outbound requests
    egress {
        from_port   = local.any_port
        to_port     = local.any_port
        protocol    = local.any_protocol  // -1 is any protocol
        cidr_blocks = local.all_ipv4
    }
}
resource "aws_lb_target_group" "asg" {
    name        = "terraform-asg-example"
    port        = var.webserver_port
    protocol    = "HTTP"
    vpc_id      = data.aws_vpc.default.id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
          values = ["*"]
        }
    }

    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.asg.arn
    }
}