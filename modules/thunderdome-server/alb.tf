# ================= #
#   Load Balancer   #
# ================= #

resource "aws_lb" "public_alb" {

  name               = "${var.project_prefix}-public-alb"
  load_balancer_type = "application"

  internal        = false
  security_groups = [aws_security_group.alb_security_group.id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = var.deletion_protection

  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_prefix}-public-alb"
  }
}


# =========================== #
#   Load Balancer Listeners   #
# =========================== #

resource "aws_lb_listener" "application_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.load_balancer_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_target_group.arn
  }
}
