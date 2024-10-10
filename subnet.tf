resource "aws_subnet" "public_subnet" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.csye6225_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}_public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]


  tags = {
    Name = "${var.vpc_name}_private_subnet_${count.index + 1}"
  }
}