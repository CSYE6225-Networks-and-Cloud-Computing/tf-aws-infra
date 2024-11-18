# # tf-aws-infra/lambda.tf

# resource "aws_lambda_function" "verify_user" {
#   filename      = "serverless-fork.zip"
#   function_name = "userVerification"
#   role          = aws_iam_role.lambda_exec.arn
#   handler       = "verifyUser.handler"
#   runtime       = "nodejs20.x"

#   # vpc_config {
#   #   subnet_ids         = [aws_subnet.private_subnet[0].id]
#   #   security_group_ids = [aws_security_group.lambda_sg.id]
#   # }

#   environment {
#     variables = {
#       SENDGRID_API_KEY = var.sendgrid_api_key
#       BASE_URL         = var.dev_domain_name
#       SNS_TOPIC_ARN    = aws_sns_topic.user_verification.arn
#       DB_USERNAME      = var.db_username
#       DB_PASSWORD      = var.db_password
#       DB_HOST          = aws_db_instance.csye6225_db.address
#       DB_NAME          = aws_db_instance.csye6225_db.db_name
#     }
#   }

#   source_code_hash = filebase64sha256(var.deployment_package)
# }

# resource "aws_iam_role" "lambda_exec" {
#   name = "serverless_lambda"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# # IAM Policy to grant permissions to Lambda
# resource "aws_iam_policy" "lambda_exec_policy" {
#   name        = "UserVerificationLambdaExecPolicy"
#   description = "Policy to allow Lambda function to access SNS, RDS, and CloudWatch."

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "sns:Publish",
#           "cloudwatch:PutMetricData",
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect   = "Allow",
#         Action   = ["ses:SendEmail", "ses:SendRawEmail"],
#         Resource = "*"
#       }

#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   policy_arn = aws_iam_policy.lambda_exec_policy.arn
#   role       = aws_iam_role.lambda_exec.name
# }

# # resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
# #   role       = aws_iam_role.lambda_exec.name
# #   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# # }


# // Security group for Lambda functions
# # resource "aws_security_group" "lambda_sg" {
# #   name        = "lambda_sg"
# #   description = "Security group for Lambda functions"
# #   vpc_id      = aws_vpc.csye6225_vpc.id

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   tags = {
# #     Name = "${var.project_name}-lambda-sg"
# #   }
# # }

# # resource "aws_security_group_rule" "lambda_to_rds" {
# #   type                     = "ingress"
# #   from_port                = 5432
# #   to_port                  = 5432
# #   protocol                 = "tcp"
# #   source_security_group_id = aws_security_group.lambda_sg.id
# #   security_group_id        = aws_security_group.database_sg.id
# # }


resource "aws_lambda_function" "verify_user" {
  filename      = "serverless-fork.zip"
  function_name = "userVerification"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "verifyUser.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      SENDGRID_API_KEY = var.sendgrid_api_key
      BASE_URL         = var.dev_domain_name
      SNS_TOPIC_ARN    = aws_sns_topic.user_verification.arn
    }
  }

  source_code_hash = filebase64sha256(var.deployment_package)
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
          "logs:PutLogEvents"
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
 