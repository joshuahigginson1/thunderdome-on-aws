
# ============== #
#   DB Cluster   #
# ============== #

resource "aws_rds_cluster" "rds_cluster" {

  # ------------------ #
  #   Cluster Config   #
  # ------------------ #

  cluster_identifier = "${var.project_prefix}-rds-cluster"
  database_name      = var.initial_database_name

  engine_mode = "provisioned" # Requirement for Aurora v2 engine.
  engine      = "aurora-${var.database_engine}"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 4
  }

  # -------------- #
  #   Networking   #
  # -------------- #

  availability_zones     = data.aws_availability_zones.available.names
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  # ------------ #
  #   Security   #
  # ------------ #

  # NB: With Serverless V2 Aurora, you must always, always, always specify 'storage_encrypted' to be true.
  storage_encrypted   = true
  deletion_protection = var.deletion_protection

  master_username             = "administrator"
  manage_master_user_password = true

  # Configures the relevant cloudwatch log exports, depending on the database engine.
  enabled_cloudwatch_logs_exports = var.database_engine == "postgresql" ? ["postgresql"] : ["audit", "error", "general", "slowquery"]

  # ----------- #
  #   Backups   #
  # ----------- #

  backup_retention_period = 7 # Configures backups for 7 consecutive days.
  preferred_backup_window = "00:00-01:00"
  copy_tags_to_snapshot   = true

  delete_automated_backups = !var.deletion_protection
  skip_final_snapshot      = var.deletion_protection

  # -------------------- #
  #   Database Changes   #
  # -------------------- #

  apply_immediately            = !var.deletion_protection
  preferred_maintenance_window = "wed:04:00-wed:04:30"

  enable_http_endpoint = !var.disable_rds_data_endpoint
}


# =============== #
#   DB Instance   #
# =============== #

resource "aws_rds_cluster_instance" "rds_instance" {

  # ------------------- #
  #   Instance Config   #
  # ------------------- #

  identifier         = "${var.project_prefix}-instance"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = "db.serverless"

  engine                     = aws_rds_cluster.rds_cluster.engine
  engine_version             = aws_rds_cluster.rds_cluster.engine_version
  auto_minor_version_upgrade = true

  publicly_accessible = false
  ca_cert_identifier  = "rds-ca-ecc384-g1"

  # -------------------------- #
  #   Backups and Monitoring   #
  # -------------------------- #

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
}