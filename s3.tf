# resource "aws_s3_bucket" "app_bucket" {
#   bucket = uuid()

#   force_destroy = true

#   lifecycle_rule {
#     enabled = true

#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }
#   }
# }
resource "aws_s3_bucket" "app_bucket" {
  bucket        = uuid()
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
#   bucket = aws_s3_bucket_lifecycle_configuration.bucket_lifecycle.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }