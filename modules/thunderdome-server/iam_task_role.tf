# The Task Role allows the applications, I.E. Any code running on ECS itself to perform AWS API Actions.
# I always get the two ECS IAM Roles mixed up, hence they are in separate .tf files.

resource "aws_iam_role" "ecs_task_role" {
  name        = "${var.project_prefix}-ecs-task-role"
  description = "The Task Role required for applications running on ECS to perform AWS API Actions."

  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
}