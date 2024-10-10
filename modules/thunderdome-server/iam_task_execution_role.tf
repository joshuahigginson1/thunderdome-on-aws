# The Task Execution Role allows ECS itself, and not the application running on ECS, to perform AWS API Actions.

# Yes:
# ECS wants to authenticate to ECR.
# ECS wants to mount a secret from AWS Secrets Manager.

# No:
# My application wants to upload data to S3.
# My application wants to write to DynamoDB.

# I always get the two ECS IAM Roles mixed up, hence they are in separate .tf files.

resource "aws_iam_role" "ecs_task_execution_role" {
  name                = "${var.project_prefix}-ecs-task-execution-role"
  description         = "The Task Execution Role required for applications running on ECS to perform AWS API Actions."
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}