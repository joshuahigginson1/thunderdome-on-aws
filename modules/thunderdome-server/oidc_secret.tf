# This file securely stores the OIDC Secret for Thunderdome inside of AWS Secrets Manager.

# =================== #
#   Secrets Manager   #
# =================== #

resource "aws_secretsmanager_secret" "oidc_secret" {
  name_prefix        = "${var.project_prefix}-oidc-secret"
  description = "An AWS Secrets Manager Secret, storing the OIDC secrets for Thunderdome."

  recovery_window_in_days = var.deletion_protection ? 30 : 0
}

resource "aws_secretsmanager_secret_policy" "oidc_secret_policy" {
  secret_arn = aws_secretsmanager_secret.oidc_secret.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_execution_role.arn
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = "*"
      },
      {
        Sid    = "AllowRootAndDeployerAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            data.aws_caller_identity.current.arn
          ]
        }
        Action = [
          "secretsmanager:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Set the value of the secret to contain the result of our random password objects above.
resource "aws_secretsmanager_secret_version" "oidc_secret_version" {
  secret_id = aws_secretsmanager_secret.oidc_secret.id
  secret_string = jsonencode({
    client_id     = "TODO"  # TODO: Not currently possible to add custom OIDC outside of google.
    client_secret = "TODO"
  })
}
