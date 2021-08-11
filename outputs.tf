output "public_ip" {
    // value = aws_instance.example.public_ip
    // use alb
    value = aws_lb.example.dns_name
    description = "The public ip address of the web server"
}