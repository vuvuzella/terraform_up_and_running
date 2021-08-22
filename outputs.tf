// output "public_ip" {
output "alb_dns_name" {
    // value = aws_instance.example.public_ip
    // description = "The public ip address of the web server"
    // use alb
    value = aws_lb.example.dns_name
    description = "The public ip address of the load balancer"
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}