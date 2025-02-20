
resource "aws_security_group" "web_app_sg" {
  name        = "application_sg"
  description = "Application security group for web apps"
  vpc_id      = aws_vpc.csye6225_vpc.id

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # security_groups = [aws_security_group.load_balancer_sg.id]
  # }

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  # ingress {
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.load_balancer_sg.id]
  # }

  # ingress {
  #   from_port       = 443
  #   to_port         = 443
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.load_balancer_sg.id]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}



data "aws_ami" "custom_ami" {
  most_recent = true

  //edit AMI name here!!!
  filter {
    name   = "name"
    values = ["ami_a08-1731958376"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# resource "aws_instance" "web_app" {
#   ami                    = data.aws_ami.custom_ami.id
#   instance_type          = var.instance_type
#   key_name               = var.key_pair_name
#   vpc_security_group_ids = [aws_security_group.web_app_sg.id]
#   subnet_id              = aws_subnet.public_subnet[0].id

#   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }
#   depends_on = [aws_db_instance.csye6225_db]
#   # echo "S3_BUCKET_NAME=${aws_s3_bucket_lifecycle_configuration.bucket_lifecycle.id}" >> /opt/csye6225/.env 
#   user_data = <<-EOF
#     #!/bin/bash
#     echo "DB_HOST=$(echo ${aws_db_instance.csye6225_db.endpoint} | cut -d':' -f1)" > /opt/csye6225/.env
#     echo "DB_PORT=${var.db_port}" >> /opt/csye6225/.env
#     echo "DB_USER=${aws_db_instance.csye6225_db.username}" >> /opt/csye6225/.env
#     echo "DB_PASSWORD=${var.db_password}" >> /opt/csye6225/.env
#     echo "APP_PORT=${var.app_port}" >> /opt/csye6225/.env
#     echo "DB_NAME=${aws_db_instance.csye6225_db.db_name}" >> /opt/csye6225/.env

#     echo "SENDGRID_API_KEY=${var.sendgrid_api_key}" >> /opt/csye6225/.env

#     echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.bucket}" >> /opt/csye6225/.env
#     echo "AWS_REGION=${var.region}" >> /opt/csye6225/.env

#     sudo touch /var/log/webapp.log
#     sudo chown csye6225:csye6225 /var/log/webapp.log
#     sudo chmod 644 /var/log/webapp.log

#     # Start CloudWatch agent
#     sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
#     sudo amazon-cloudwatch-agent-ctl -a start
#     # Restart webapp service
#     systemctl restart webapp.service
#   EOF

#   disable_api_termination = false


#   tags = {
#     Name = "${var.project_name}-a06-trial01"
#   }
# }


// ---------- Assignment 05 addition code ----------
resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_sg.id]
  }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "${var.project_name}-database-sg"
  }
}

resource "aws_db_parameter_group" "custom_pg" {
  family = "postgres14" # Adjust based on your DB engine and version
  name   = "csye6225-pg"

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }
}

// A09 - RDS instance - password management
resource "random_password" "db_password" {
  length  = 16
  special = false

}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "db-password"
  kms_key_id              = aws_kms_key.secret_manager_key.arn
  recovery_window_in_days = 0

}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = random_password.db_password.result })
}

# data "aws_secretsmanager_secret_version" "db_password_version" {
#   secret_id = aws_secretsmanager_secret.db_password.id
# }
// end.

// RDS instance
resource "aws_db_instance" "csye6225_db" {
  identifier        = var.db_identifier
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  db_name           = var.db_name
  username          = var.db_username
  # password          = var.db_password
  password = random_password.db_password.result
  # password          = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)["password"]
  kms_key_id        = aws_kms_key.rds_kms_key.arn
  storage_encrypted = true

  parameter_group_name = aws_db_parameter_group.custom_pg.name
  skip_final_snapshot  = true
  multi_az             = false
  publicly_accessible  = false
  apply_immediately    = true

  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.private.name

  tags = {
    Name = "${var.project_name}-rds"
  }
}

resource "aws_db_subnet_group" "private" {
  name       = "csye6225-private-subnet-group"
  subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id, aws_subnet.private_subnet[2].id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

// ---------- Assignment 07 addition code ----------

// load balancer security group
resource "aws_security_group" "load_balancer_sg" {
  name        = "load_balancer_sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-lb-sg"
  }
}

