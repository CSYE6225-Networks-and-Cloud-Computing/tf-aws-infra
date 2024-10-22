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

variable "db_port" {
  type    = number
  default = 5432
}