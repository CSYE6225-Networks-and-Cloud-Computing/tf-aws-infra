output "s3_bucket_name" {
  value       = aws_s3_bucket.app_bucket.id
  description = "The name of the S3 bucket"
}

output "app_url" {
  value       = "http://${aws_route53_record.webapp.name}:${var.app_port}"
  description = "The URL of the web application"
}
