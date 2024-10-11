# =================== #
#   Standard Oututs   #
# =================== #

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The VPC ID of the VPC created by this Terraform module."
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnets[*].id
  description = "A list of Private Subnet IDs created by the Terraform module."
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnets[*].id
  description = "A list of Public Subnet IDs created by the Terraform module."
}