variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "region" {
  description = "region to deploy the resources in"
  type        = string
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "public_cidrs" {
  description = "values of public cidrs"
  type        = list(string)
}

variable "subnet_count" {
  description = "number of public subnets to be created"
  type        = number
}

variable "private_cidrs" {
  description = "values of private cidrs"
  type        = list(string)
}

variable "public_route_cidr" {
  description = "CIDR block for public route"
  type        = string
}

variable "ami_id" {
  description = "AMI_ID for the instance"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "key_pair_name" {
  type    = string
  default = "aws_key_pair"
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "project_name" {
  type = string
}

variable "db_password" {
  type    = string
  default = "csye6225"
}

variable "db_username" {
  type    = string
  default = "csye6225"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "environment" {
  description = "Deployment environment (dev or demo)"
  type        = string
  default     = "dev"
}

variable "dev_domain_name" {
  description = "domain name for dev account"
  type        = string
}

variable "dev_route53_zone_id" {
  description = "value of dev route53 zone id"
  type        = string
}

variable "demo_domain_name" {
  description = "domain name for demo account"
  type        = string
}

variable "demo_route53_zone_id" {
  description = "value of demo route53 zone id"
  type        = string
}

variable "sendgrid_api_key" {
  description = "Sendgrid API key"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 3
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
  default     = 3
}

variable "scale_up_adjustment" {
  description = "Number of instances to add when scaling up"
  type        = number
  default     = 1
}

variable "scale_up_cooldown" {
  description = "Cooldown period after a scaling activity, in seconds"
  type        = number
  default     = 60
}

variable "scale_up_policy_type" {
  description = "The type of scaling policy"
  type        = string
  default     = "SimpleScaling"
}

variable "scale_down_adjustment" {
  description = "Number of instances to remove when scaling down"
  type        = number
  default     = -1
}

variable "scale_down_cooldown" {
  description = "Cooldown period after a scaling-down activity, in seconds"
  type        = number
  default     = 60
}

variable "scale_down_policy_type" {
  description = "The type of scaling-down policy"
  type        = string
  default     = "SimpleScaling"
}
variable "high_cpu_threshold" {
  description = "CPU utilization threshold for scaling up"
  type        = number
  default     = 8
}

variable "low_cpu_threshold" {
  description = "CPU utilization threshold for scaling down"
  type        = number
  default     = 6
}

variable "cpu_evaluation_periods" {
  description = "The number of evaluation periods for CPU alarms"
  type        = number
  default     = 2
}

variable "cpu_period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = number
  default     = 60
}

variable "cpu_statistic" {
  description = "The statistic to apply to the alarm's associated metric"
  type        = string
  default     = "Average"
}

variable "cpu_metric_name" {
  description = "The name of the metric to alarm on"
  type        = string
  default     = "CPUUtilization"
}

variable "cpu_namespace" {
  description = "The namespace of the metric"
  type        = string
  default     = "AWS/EC2"
}

variable "health_check_grace_period" {
  description = "value of health check grace period"
  type        = number
  default     = 300
}

variable "health_check_interval" {
  description = "The interval, in seconds, between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, before the health check times out"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "The number of consecutive successful health checks required before considering an unhealthy target healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "The number of consecutive failed health checks required before considering a target unhealthy"
  type        = number
  default     = 10
}

variable "health_check_matcher" {
  description = "The HTTP response code to use when checking for a healthy target"
  type        = string
  default     = "200"
}

variable "db_identifier" {
  description = "The identifier for the DB instance"
  type        = string
  default     = "csye6225"
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "14.13"
}

variable "db_instance_class" {
  description = "The instance class for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The amount of storage allocated to the database instance (in GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "csye6225"
}