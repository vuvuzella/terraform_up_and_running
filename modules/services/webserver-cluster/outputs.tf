output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "The public ip address of the load balancer"
}

// output "ec2_instance_public_ip" {
//   value = aws_instance.example.public_ip
// }

output "asg_name" {
    value = aws_autoscaling_group.example.name
    description = "The name of the Auto Scaling Group"
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
  description = "Security group id for the alb"
}