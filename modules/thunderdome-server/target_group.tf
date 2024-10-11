resource "aws_lb_target_group" "application_target_group" {
  name        = "${var.project_prefix}-app-target-group"
  target_type = "ip"  # ECS Fargate Tasks can only have the IP target type.

  vpc_id      = var.vpc_id

  port        = 8080
  protocol    = "HTTP"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"  # TODO: Improve healthcheck path.
    port                = "8080"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_prefix}-app-target-group"
  }
}