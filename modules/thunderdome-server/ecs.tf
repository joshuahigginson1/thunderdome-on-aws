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

  cpu    = 512  # 0.5 vCPU
  memory = 1024 # 1GB RAM

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64" # Instant 20% Saving
  }

  # NB: Container Definitions will vary massively from deployment to deployment. You will want to edit this section by hand.
  container_definitions = jsonencode([

    # ====================== #
    #   Application Server   #
    # ====================== #

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

        # -------------------- #
        #   Database Secrets   #
        # -------------------- #

        {
          name      = "DB_USER",
          valueFrom = "${var.database_secret_arn}:username::"
        },
        {
          name      = "DB_PASS",
          valueFrom = "${var.database_secret_arn}:password::"
        },

        # ----------------------- #
        #   Application Secrets   #
        # ----------------------- #

        {
          name      = "COOKIE_HASHKEY",
          valueFrom = "${aws_secretsmanager_secret.hashkey_secret.arn}:cookie_hashkey::"
        },
        {
          name      = "CONFIG_AES_HASHKEY",
          valueFrom = "${aws_secretsmanager_secret.hashkey_secret.arn}:aes_hashkey::"
        }
      ]

      # Config found here: https://github.com/StevenWeathers/thunderdome-planning-poker/blob/main/docs/CONFIGURATION.md
      environment = [

        # ----------------------------- #
        #   Application Configuration   #
        # ----------------------------- #

        {
          name  = "APP_DOMAIN",
          value = aws_route53_record.application_entry.fqdn
        },
        {
          name  = "ADMIN_EMAIL",
          value = "${var.thunderdome_administrator_email}"
        },
        {
          name  = "SMTP_ENABLED",
          value = "false" # Disable SMTP, we don't want to be sending emails to users.
        },
        {
          name  = "CONFIG_ALLOW_EXTERNAL_API",
          value = "false" # Disable External API for my deployment. I'm not certainly not using it.
        },
        {
          name  = "CONFIG_CLEANUP_GUESTS_DAYS_OLD",
          value = "7"
        },

        # -------------------------- #
        #   Database Configuration   #
        # -------------------------- #

        {
          name  = "DB_NAME",
          value = "${var.database_name}"
        },
        {
          name  = "DB_HOST",
          value = "${var.database_endpoint}"
        },
        # TODO: Configure SSL on DB Connection - Requires custom container to mount certificate.
        # {
        #   name  = "DB_SSLMODE",
        #   value = "verify-full"
        # },

        # -------------------------------- #
        #   Monitoring and Observability   #
        # -------------------------------- #

        {
          name  = "OTEL_ENABLED",
          value = "true"
        },
        {
          name  = "OTEL_INSECURE_MODE",
          value = "true" # TODO: Secure.
        }
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
    },

    # ================== #
    #   OTEL Collector   #
    # ================== #

    # Collects OpenTelemetry information from the container and feeds it to AWS XRay.
    {
      name      = "aws-otel-collector"
      image     = "public.ecr.aws/aws-observability/aws-otel-collector:v0.41.0"
      essential = true
      user      = "aoc"

      entryPoint = [
        "/awscollector",
        "--config=/etc/otel-config.yaml"
      ]

      healthCheck = {
        command = [
          "/healthcheck"
        ],
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log_group.name
          mode                  = "non-blocking"
          max-buffer-size       = "25m"
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "otel-collector"
        }
      }
    }
  ])
}