resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.project_prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}