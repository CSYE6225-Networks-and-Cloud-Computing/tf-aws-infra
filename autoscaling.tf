// app launch template
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = data.aws_ami.custom_ami.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_app_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # A09 updates - EBS encryption
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp2"
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_kms_key.arn
    }
  }


  # ----- addition of kms stuff here -----
  # echo "SENDGRID_SECRET_NAME=${aws_secretsmanager_secret.sendgrid_api_key.name}" >> /opt/csye6225/.env
  # echo "DOMAIN=${aws_secretsmanager_secret.domain.name}" >> /opt/csye6225/.env
  #  echo "DB_PASSWORD=${var.db_password}" >> /opt/csye6225/.env

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "DB_HOST=$(echo ${aws_db_instance.csye6225_db.endpoint} | cut -d':' -f1)" > /opt/csye6225/.env
    echo "DB_PORT=${var.db_port}" >> /opt/csye6225/.env
    echo "DB_USER=${aws_db_instance.csye6225_db.username}" >> /opt/csye6225/.env
    echo "DB_PASSWORD=${random_password.db_password.result}" >> /opt/csye6225/.env
    echo "APP_PORT=${var.app_port}" >> /opt/csye6225/.env
    echo "DB_NAME=${aws_db_instance.csye6225_db.db_name}" >> /opt/csye6225/.env
    echo "SENDGRID_API_KEY=${var.sendgrid_api_key}" >> /opt/csye6225/.env
    echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.bucket}" >> /opt/csye6225/.env
    echo "AWS_REGION=${var.region}" >> /opt/csye6225/.env
    echo "SNS_TOPIC_ARN=${aws_sns_topic.user_verification.arn}" >> /opt/csye6225/.env

    # creating log file to store logs from CloudWatch
    sudo touch /var/log/webapp.log
    sudo chown csye6225:csye6225 /var/log/webapp.log
    sudo chmod 644 /var/log/webapp.log

    # starting CloudWatch agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    sudo amazon-cloudwatch-agent-ctl -a start

    # restarting webapp.service
    sudo systemctl restart webapp.service
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-asg-instance"
    }
  }
}

// autoscaling group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-asg"
  vpc_zone_identifier       = aws_subnet.public_subnet[*].id
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}

// autoscaling : scale up policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_up_adjustment
  cooldown               = var.scale_up_cooldown
  policy_type            = var.scale_up_policy_type
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_evaluation_periods
  metric_name         = var.cpu_metric_name
  namespace           = var.cpu_namespace
  period              = var.cpu_period
  statistic           = var.cpu_statistic
  threshold           = var.high_cpu_threshold
  alarm_description   = " Scale up when CPU usage is above 80%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

// autoscaling : scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_down_adjustment
  cooldown               = var.scale_down_cooldown
  policy_type            = var.scale_down_policy_type
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cpu_evaluation_periods
  metric_name         = var.cpu_metric_name
  namespace           = var.cpu_namespace
  period              = var.cpu_period
  statistic           = var.cpu_statistic
  threshold           = var.low_cpu_threshold
  alarm_description   = " Scale down when CPU usage is below 40%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}