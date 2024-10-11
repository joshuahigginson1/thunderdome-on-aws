# ============================== #
#   Container Security Group   #
# ============================== #

resource "aws_security_group" "rds_security_group" {
  name        = "${var.project_prefix}-rds-security-group"
  description = "Security Group, attached to RDS, acting as an anchor to allow access into it by the RDS Access Security Group."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "rds_access_ingress" {
  security_group_id        = aws_security_group.rds_security_group.id
  type                     = "ingress"
  from_port                = aws_rds_cluster.rds_cluster.port
  to_port                  = aws_rds_cluster.rds_cluster.port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_access_security_group.id
}

# ================================= #
#   Load Balancer Security Groups   #
# ================================= #

resource "aws_security_group" "rds_access_security_group" {
  name        = "${var.project_prefix}-rds-access-security-group"
  description = "Allows outbound connections to the RDS Security Group."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "rds_egress" {
  security_group_id        = aws_security_group.rds_access_security_group.id
  type                     = "egress"
  from_port                = aws_rds_cluster.rds_cluster.port
  to_port                  = aws_rds_cluster.rds_cluster.port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_security_group.id
}