
resource "aws_security_group" "web_app_sg" {
  name        = "application_sg"
  description = "Application security group for web apps"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}



data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["self"]

  //edit AMI name here!!!
  filter {
    name   = "name"
    values = ["ami_a05-1729621179*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "web_app" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
  subnet_id              = aws_subnet.public_subnet[0].id

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # 
  # user_data = (<<-EOF
  #   #!/bin/bash
  #   echo "DB_HOST=${aws_db_instance.csye6225_db.endpoint}" >> /opt/csye6225/.env
  #   # app_port
  #   echo "DB_USER=${aws_db_instance.csye6225_db.username}" >> /opt/csye6225/.env
  #   echo "DB_PASSWORD=${var.db_password}" >> /opt/csye6225/.env
  #   echo "DB_NAME=${aws_db_instance.csye6225_db.db_name}" >> /opt/csye6225/.env
  #   systemctl restart webapp.service
  # EOF
  # )
  user_data = (<<-EOF
  #!/bin/bash
  echo "DB_HOST=$(echo ${aws_db_instance.csye6225_db.endpoint} | cut -d':' -f1)" > /opt/csye6225/.env
  echo "DB_PORT=${var.db_port}" >> /opt/csye6225/.env
  echo "DB_USER=${aws_db_instance.csye6225_db.username}" >> /opt/csye6225/.env
  echo "DB_PASSWORD=${var.db_password}" >> /opt/csye6225/.env
  echo "APP_PORT=${var.app_port}" >> /opt/csye6225/.env
  echo "DB_NAME=${aws_db_instance.csye6225_db.db_name}" >> /opt/csye6225/.env

  # Debug output
  echo "Environment variables:" > /tmp/debug_env.log
  cat /opt/csye6225/.env >> /tmp/debug_env.log

  systemctl restart webapp.service
  EOF
  )

  disable_api_termination = false

  tags = {
    Name = "${var.project_name}-a05-trial01"
  }
}


// ---------- Assignment 05 addition code ----------
resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port       = 5432 # for PostgreSQL
    to_port         = 5432 # for PostgreSQL
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  # Add more parameters as needed
}

resource "aws_db_instance" "csye6225_db" {
  identifier           = "csye6225"
  engine               = "postgres"    # your chosen db engine
  engine_version       = "14.13"       # Adjust based on your chosen version
  instance_class       = "db.t3.micro" # CHECK THE DOCS FOR THE RIGHT INSTANCE CLASS
  allocated_storage    = 20
  db_name              = "csye6225"
  username             = "csye6225"
  password             = var.db_password # Use a variable for the password
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