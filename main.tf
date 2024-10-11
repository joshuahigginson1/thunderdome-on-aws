module "vpc" {
  source         = "./modules/simple-vpc"
  project_prefix = local.project_prefix
  max_subnets    = 3

}

module "thunderdome_server" {
  source = "./modules/thunderdome-server"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  ecs_cluster_arn = aws_ecs_cluster.ecs_cluster.arn

  deletion_protection = var.deletion_protection
  project_prefix      = local.project_prefix
}