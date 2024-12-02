# resource "aws_lambda_function" "verify_user" {
#   filename      = "serverless-fork.zip"
#   function_name = "userVerification"
#   role          = aws_iam_role.lambda_exec.arn
#   handler       = "verifyUser.handler"
#   runtime       = "nodejs20.x"

#   environment {
#     variables = {
#       SENDGRID_API_KEY = var.sendgrid_api_key
#       BASE_URL         = var.dev_domain_name
#       SNS_TOPIC_ARN    = aws_sns_topic.user_verification.arn
#     }
#   }

#   source_code_hash = filebase64sha256(var.deployment_package)
# }

data "aws_s3_bucket" "lambda_code_bucket" {
  # bucket = "serverless-bucket-hir-demo"
  bucket = "serverless-bucket-hir-new"
}

resource "aws_lambda_function" "verify_user" {
  function_name = "userVerification"
  s3_bucket     = data.aws_s3_bucket.lambda_code_bucket.id
  s3_key        = "serverless-fork.zip"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "verifyUser.handler"
  runtime       = "nodejs20.x"

  environment {
    # variables = {
    #   SENDGRID_API_KEY = var.sendgrid_api_key
    #   SENDGRID_SECRET_NAME = aws_secretsmanager_secret.sendgrid_api_key.name // A09 - secrets manager retrieval
    #   BASE_URL      = var.demo_domain_name
    #   SNS_TOPIC_ARN = aws_sns_topic.user_verification.arn
    # }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy to grant permissions to Lambda
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "UserVerificationLambdaExecPolicy"
  description = "Policy to allow Lambda function to access SNS, RDS, and CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish",
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["ses:SendEmail", "ses:SendRawEmail"],
        Resource = "*"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "LambdaS3AccessPolicy"
  description = "Allow Lambda to access S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${data.aws_s3_bucket.lambda_code_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.lambda_exec.name
}
