# =========== #
#   Network   #
# =========== #

# This file contains the generation of our core networking resources - the VPC and subnets inside.


# ------- #
#   VPC   #
# ------- #

resource "aws_vpc" "vpc" {
  # TODO: Parameterise CIDR Block / Move to IPv6.
  cidr_block = "12.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "${var.project_prefix}-vpc"
  }
}


# ----------- #
#   Subnets   #
# ----------- #

# Loop through the calculations provided in our `locals.tf` file to generate our unique Subnets.

resource "aws_subnet" "public_subnets" {
  count             = local.num_subnets_to_create
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(local.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = local.num_subnets_to_create
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(local.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_prefix}-private-subnet-${count.index + 1}"
  }
}

