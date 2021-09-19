output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "The public ip address of the load balancer"
}

// output "ec2_instance_public_ip" {
//   value = aws_instance.example.public_ip
// }