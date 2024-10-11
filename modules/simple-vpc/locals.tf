locals {

  # Calculate the number of subnets to automatically create.
  # Value is calculated by using the number of availability zones in the target AWS region, limited by the 'max_subnets' variable.

  # TODO: Move to IPv6.

  num_subnets_to_create = min(length(data.aws_availability_zones.available.names), var.max_subnets)

  # Break down the provided CIDR block into /24 blocks.
  subnet_cidrs = [for idx in range(local.num_subnets_to_create * 2) :
  cidrsubnet("12.0.0.0/16", 8, idx)]

  # Starting at index 0, take the next x subnets.
  private_subnet_cidrs = slice(local.subnet_cidrs, 0, local.num_subnets_to_create)

  # Starting at index x+1, take the next x subnets.
  public_subnet_cidrs = slice(local.subnet_cidrs, local.num_subnets_to_create, local.num_subnets_to_create * 2)
}