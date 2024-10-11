# A collection of subnets that you can use to designate for your RDS database instance in a VPC.
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
}