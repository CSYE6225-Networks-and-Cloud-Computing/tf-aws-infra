resource "aws_iam_role" "ec2_role" {
  name = "ec2_cloudwatch_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "custom_s3_policy" {
  name        = "custom_s3_policy"
  path        = "/"
  description = "Custom S3 policy for EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.app_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.app_bucket.bucket}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "custom_s3_policy_attachment" {
  policy_arn = aws_iam_policy.custom_s3_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "custom_cloudwatch_policy" {
  name        = "custom_cloudwatch_policy"
  path        = "/"
  description = "Custom CloudWatch policy for EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_cloudwatch_policy_attachment" {
  policy_arn = aws_iam_policy.custom_cloudwatch_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_cloudwatch_s3_profile"
  role = aws_iam_role.ec2_role.name
}


# resource "aws_iam_role" "ec2_role" {
#   name = "ec2_cloudwatch_s3_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#   role       = aws_iam_role.ec2_role.name
# }

# resource "aws_iam_role_policy_attachment" "s3_full_access" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#   role       = aws_iam_role.ec2_role.name
# }

# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "ec2_cloudwatch_s3_profile"
#   role = aws_iam_role.ec2_role.name
# }