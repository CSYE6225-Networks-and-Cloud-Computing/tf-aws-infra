resource "aws_kms_key" "ec2_kms_key" {
  description             = "KMS key for EC2 EBS encryption"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS database"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 buckets"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}

resource "aws_kms_key" "secret_manager_key" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 7
  rotation_period_in_days = 90
  enable_key_rotation     = true
  multi_region            = true
}


#  aws_secretsmanager_secret : secrets manager
resource "aws_secretsmanager_secret" "sendgrid_api_key" {
  name                    = "sendgrid-api-key-new"
  kms_key_id              = aws_kms_key.secret_manager_key.arn
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sendgrid_api_key_version" {
  secret_id     = aws_secretsmanager_secret.sendgrid_api_key.id
  secret_string = jsonencode({ SENDGRID_API_KEY = var.sendgrid_api_key })
}

# Secret for Domain
resource "aws_secretsmanager_secret" "domain" {
  name                    = "app-domain"
  kms_key_id              = aws_kms_key.secret_manager_key.arn
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "domain_version" {
  secret_id     = aws_secretsmanager_secret.domain.id
  secret_string = jsonencode({ BASE_URL = "${var.demo_domain_name}" })
}