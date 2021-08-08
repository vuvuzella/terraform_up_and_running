output "public_ip" {
    value = aws_instance.example.public_ip
    description = "The public ip address of the web server"
}