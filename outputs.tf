// output "public_ip" {
output "alb_dns_name" {
    // value = aws_instance.example.public_ip
    // description = "The public ip address of the web server"
    // use alb
    value = aws_lb.example.dns_name
    description = "The public ip address of the load balancer"
}