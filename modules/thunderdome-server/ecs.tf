# =============== #
#   ECS Service   #
# =============== #

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project_prefix}-service"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn

  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  desired_count = 1

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids

    security_groups = [
      aws_security_group.container_security_group.id,
      var.database_access_security_group_id
    ]
  }

  # NB: You will want to edit these values if using this repository as a template.
  load_balancer {
    target_group_arn = aws_lb_target_group.application_target_group.arn
    container_name   = "thunderdome-server"
    container_port   = 8080
  }
}


# ======================= #
#   ECS Task Definition   #
# ======================= #

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.project_prefix}-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  cpu    = 1024 # 1 vCPU
  memory = 2048 # 2GB RAM

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64" # Instant 20% Saving
  }

  # NB: Container Definitions will vary massively from deployment to deployment. You will want to edit this section by hand.
  container_definitions = jsonencode([
    {
      name = "thunderdome-server"

      # TODO: Build this image by hand in the GitHub pipeline. Original Image is scratch, and doesn't contain the AWS Logging Binaries.
      image     = "stevenweathers/thunderdome-planning-poker:v4.16.5"
      essential = true

      user       = "65534:65534" # Run as the non-root 'nobody' user.
      privileged = false         # Run without privileged permissions inside of the container.

      # ------------------------------------- #
      #   Secrets and Environment Variables   #
      # ------------------------------------- #

      # Add / Alter secrets and app configuration via Environment Variables here.

      secrets = [
        {
          name      = "DB_USER",
          valueFrom = "${var.database_secret_arn}:username::"
        },
        {
          name      = "DB_PASS",
          valueFrom = "${var.database_secret_arn}:password::"
        }
      ]

      # TODO: Configure app.
      # Config found here: https://github.com/StevenWeathers/thunderdome-planning-poker/blob/main/docs/CONFIGURATION.md
      environment = [
        {
          name  = "ADMIN_EMAIL",
          value = "${var.thunderdome_administrator_email}"
        },
        {
          name  = "SMTP_ENABLED",
          value = "false"  # Disable SMTP, currently not configured.
        },
        {
          name  = "DB_NAME",
          value = "${var.database_name}"
        },
        {
          name  = "DB_HOST",
          value = "${var.database_endpoint}"
        },
        {
          name  = "ANALYTICS_ENABLED",
          value = "false"
        } # TODO: Can we configure Matomo here?
      ]

      # -------------------- #
      #   Command Override   #
      # -------------------- #

      # I generally like to override the original entrypoint of any container to allow for better customisation and flexibility.
      # NB: Current container has no shell, so we can't run healthchecks or command overrides.

      # entryPoint = [
      #   "sh",
      #   "-c"
      # ]

      # command = [
      #   <<-EOF
      #   echo "Starting the Thunderdome..."
      #   /go/bin/thunderdome
      #   EOF
      # ]

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      # healthCheck = {
      #   command = [
      #     "CMD-SHELL",
      #     "curl -f http://0.0.0.0:8080/ || exit 1"
      #   ],
      #   startPeriod = 30
      # } NB: Current container has no shell.

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log_group.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "thunderdome-server"
        }
      }
    }
  ])
}