module "vpc" {
  source = "./modules/simple-vpc"

  max_subnets = 3

  project_prefix = local.project_prefix
}

module "rds" {
  source = "./modules/rds"

  initial_database_name = "thunderdome"
  database_engine       = "postgresql"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  deletion_protection = var.deletion_protection
  project_prefix      = local.project_prefix
}

module "thunderdome_server" {
  source = "./modules/thunderdome-server"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  ecs_cluster_arn = aws_ecs_cluster.ecs_cluster.arn

  database_name                     = module.rds.rds_initial_database_name
  database_endpoint                 = module.rds.rds_database_endpoint
  database_secret_arn               = module.rds.rds_secret_arn
  database_access_security_group_id = module.rds.rds_access_security_group_id

  thunderdome_administrator_email = var.thunderdome_administrator_email

  deletion_protection = var.deletion_protection
  project_prefix      = local.project_prefix
}