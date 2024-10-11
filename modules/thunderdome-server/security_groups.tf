# ============================== #
#   Container Security Group   #
# ============================== #

resource "aws_security_group" "container_security_group" {
  name        = "${var.project_prefix}-container-security-group"
  description = "Security Group to allow connections from the Load Balancer to the container."
  vpc_id      = var.vpc_id
}

# NB: If using this repository as a template, you will want to add any port in which you would like exposed to the load balancer below. Copy and paste the below resource for as many ports as you need.

resource "aws_security_group_rule" "container_to_internet_egress" {
  security_group_id = aws_security_group.container_security_group.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_to_container_ingress" {
  security_group_id        = aws_security_group.container_security_group.id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_security_group.id
}

# ================================= #
#   Load Balancer Security Groups   #
# ================================= #

resource "aws_security_group" "alb_security_group" {
  name        = "${var.project_prefix}-alb-security-group"
  description = "Allows inbound connections ports to the Load Balancer, and egress to the container security group."
  vpc_id      = var.vpc_id

  # Outbound only to the container security group. NB: Ensure that you have as many egresses as there are ports exposed on the container ingess.

  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.container_security_group.id]
  }
}

resource "aws_security_group_rule" "internet_to_lb_ingress" {

  security_group_id = aws_security_group.alb_security_group.id
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}