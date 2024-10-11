# ================ #
#   Connectivity   #
# ================ #

# This file contains everything pertaining to connectivity - our Route Tables and Gateways.
# NB: This module is named 'simple-vpc' as I would like to integrate an EC2-based NATing solution in the future.

# ----------------------- #
#   Public Connectivity   #
# ----------------------- #

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_prefix}-internet-gw"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_prefix}-public-rt"
  }
}

# Associate our Public Route Table with all of our public subnets, created in `network.tf`.
resource "aws_route_table_association" "public_rt_associations" {
  count          = local.num_subnets_to_create
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}


# ------------------------ #
#   Private Connectivity   #
# ------------------------ #

# Create Elastic IP addresses for our NATs.

resource "aws_eip" "nat_eips" {
  count  = local.num_subnets_to_create
  domain = "vpc"

  tags = {
    Name = "${var.project_prefix}-eip-${count.index + 1}"
  }
}

# Create our NATs, based off of the number of public subnets we have available to us.
resource "aws_nat_gateway" "nat_gateways" {

  count         = local.num_subnets_to_create
  allocation_id = element(aws_eip.nat_eips[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name = "${var.project_prefix}-nat-gw-${count.index + 1}"
  }
}

# Automatically configure our private route tables with a looping function.
resource "aws_route_table" "private_route_tables" {
  vpc_id = aws_vpc.vpc.id

  count = local.num_subnets_to_create

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateways[*].id, count.index)
  }

  tags = {
    Name = "${var.project_prefix}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_rt_associations" {
  count          = local.num_subnets_to_create
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_route_tables[*].id, count.index)
}
