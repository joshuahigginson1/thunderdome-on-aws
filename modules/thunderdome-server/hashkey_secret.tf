# This file creates two random hashkeys for securing Thunderdome, before storing them as a secret to AWS Secrets Manager.

# ============ #
#   Hashkeys   #
# ============ #

resource "random_password" "cookie_hashkey" {
  length  = 32
  special = false
}

resource "random_password" "aes_hashkey" {
  length  = 32
  special = false
}


# =================== #
#   Secrets Manager   #
# =================== #

resource "aws_secretsmanager_secret" "hashkey_secret" {
  name_prefix = "${var.project_prefix}-hashkey-secret"
  description = "An AWS Secrets Manager Secret, storing the Hashkey secrets for Thunderdome."

  recovery_window_in_days = var.deletion_protection ? 30 : 0
}

resource "aws_secretsmanager_secret_policy" "hashkey_secret_policy" {
  secret_arn = aws_secretsmanager_secret.hashkey_secret.arn
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
resource "aws_secretsmanager_secret_version" "hashkey_secret_version" {
  secret_id = aws_secretsmanager_secret.hashkey_secret.id
  secret_string = jsonencode({
    cookie_hashkey = random_password.cookie_hashkey.result
    aes_hashkey    = random_password.aes_hashkey.result
  })

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
