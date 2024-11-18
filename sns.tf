resource "aws_sns_topic" "user_verification" {
  name = "user-verification-topic"
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.verify_user.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification.arn
}

resource "aws_sns_topic_subscription" "user_verification_target" {
  topic_arn = aws_sns_topic.user_verification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.verify_user.arn
}



resource "aws_iam_policy" "ec2_sns_publish" {
  name = "ec2_sns_publish"
  # role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish",
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.user_verification.arn
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_sns_publish" {
  name       = "ec2_sns_publish"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_sns_publish.arn
}
