output "s3_bucket_name" {
  value       = aws_s3_bucket.app_bucket.id
  description = "The name of the S3 bucket"
}

output "app_url" {
  value       = "https://${aws_route53_record.webapp.name}:${var.app_port}"
  description = "The URL of the web application"
}

output "load_balancer_dns" {
  value       = aws_lb.app_lb.dns_name
  description = "The DNS name of the load balancer"
}

# Output the SNS topic ARN (you'll need this in your application)
output "sns_topic_arn" {
  value       = aws_sns_topic.user_verification.arn
  description = "value of the SNS topic ARN"
}

# Output the RDS database password
# output "db_password" {
#   value       = random_password.db_password.result
#   description = "The randomly generated password for the database"
#   sensitive   = true
# }