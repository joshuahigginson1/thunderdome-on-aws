resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.project_prefix}-log-group"

  log_group_class   = "STANDARD" # ECS ONLY works with standard log group class.
  skip_destroy      = var.deletion_protection
  retention_in_days = 90 # TODO: Parameterise this.
}
