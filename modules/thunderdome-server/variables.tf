# =========== #
#   General   #
# =========== #

# ----------------------- #
#   Deletion Protection   #
# ----------------------- #

variable "deletion_protection" {
  type        = bool
  description = "(Required) Enables deletion protection for the ECS Deployment. When set to 'true', resources cannot be deleted directly via the AWS Console or API, safeguarding against accidental deletion."
}


# ------------------ #
#   Project Naming   #
# ------------------ #

variable "project_prefix" {
  type        = string
  description = "(Required) The name of the project or application, used as the prefix for resource names created in AWS. Partially for my ease of use, to improve the re-usability of this deployment pattern."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_prefix))
    error_message = "The project prefix must consist of lowercase letters, numbers, and hyphens only. Use Terraform transformations at the resource layer to improve readability at the Resource level."
  }

  validation {
    condition     = length(var.project_prefix) > 2
    error_message = "For the sake of your fellow Platforms Engineers, give your project resources a proper name greater than 2 characters."
  }

  validation {
    condition     = length(var.project_prefix) <= 24
    error_message = "The project prefix should be under 24 characters, to prevent resource naming limits."
  }

  validation {
    condition     = !endswith(var.project_prefix, "-")
    error_message = "The project prefix ends with a dash '-' This will cause dash--repetition in resource names. Please remove it and run your terraform function again."
  }
}


# ============== #
#   Networking   #
# ============== #

variable "vpc_id" {
  type        = string
  description = "(Required) The VPC ID in which to deploy our underlying ECS containers into."

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id set is not a valid VPC ID."
  }

}

variable "private_subnet_ids" {
  description = "(Required) A list of subnet_ids, corresponding to Private Subnets within the VPC defined in the variable 'vpc_id'. Double-check that each provided subnet_id is in a unique availability zone, this is not something that Terraform can easily validate."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) > 1
    error_message = "At least two subnet_ids must be provided in the list of private_subnet_ids, to automatically recover from AZ failover."
  }

  validation {
    condition = alltrue([
      for id in var.private_subnet_ids : can(regex("^subnet-", id))
    ])
    error_message = "There is an invalid subnet_id within the list of provided private_subnet_ids."
  }
}

variable "public_subnet_ids" {
  description = "(Required) A list of subnet_ids, corresponding to Public Subnets within the VPC defined in the variable 'vpc_id'. Double-check that each provided subnet_id is in a unique availability zone, this is not something that Terraform can easily validate."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) > 1
    error_message = "At least two subnet_ids must be provided in the list of public_subnet_ids, to automatically recover from AZ failover."
  }

  validation {
    condition = alltrue([
      for id in var.public_subnet_ids : can(regex("^subnet-", id))
    ])
    error_message = "There is an invalid subnet_id within the list of provided public_subnet_ids."
  }
}


# ======= #
#   ECS   #
# ======= #

variable "ecs_cluster_arn" {
  type        = string
  description = "(Required) The ARN of the ECS Cluster in which to deploy our ECS service and containers to."

  # TODO: Tweak this regex to allow for different AWS partitions.
  validation {
    condition     = can(regex("^arn:aws:ecs:[a-z0-9-]+:[0-9]{12}:cluster/[a-zA-Z0-9-_]+$", var.ecs_cluster_arn))
    error_message = "Invalid ARN for ecs_cluster_arn. It should look something like: arn:<Your AWS Partition>:ecs:<AWS Region>:<Account ID>:cluster/<Cluster Name>"
  }
}


# ======= #
#   RDS   #
# ======= #

variable "database_secret_arn" {
  type        = string
  description = "(Required) The ARN of a Secret in AWS Secrets Manager, containing the Administrator Username and Password for the PostGres Database. Keys must be explicitly titled 'username' and 'password'."

  validation {
    # TODO: Tweak this regex to allow for different AWS partitions.
    condition     = can(regex("^arn:aws:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:[a-zA-Z0-9\\-_/!]+$", var.database_secret_arn))
    error_message = "Invalid ARN for rds_secret_arn. It should look something like: arn:<Your AWS Partition>:secretsmanager:<AWS Region>:<Account ID>:secret:<Secret Name>"
  }
}

variable "database_name" {
  description = "(Required) The PostGres database name configured for the application."
  type        = string

  validation {
    condition     = can(regex("^[a-z_]+$", var.database_name))
    error_message = "The database name must only contain lowercase letters and underscores, conforming to lower_camel_case style."
  }

  validation {
    condition     = length(var.database_name) > 2
    error_message = "Your database name should really exceed two characters in length..."
  }

  validation {
    condition     = length(var.database_name) <= 63
    error_message = "The initial database name must not exceed 63 characters, which is the maximum length for both PostgreSQL and MySQL hosted on AWS."
  }
}

variable "database_endpoint" {
  type        = string
  description = "(Required) The DNS name at which the RDS database is accessible from inside of the deployed VPC."
}

variable "database_access_security_group_id" {
  type        = string
  description = "(Required) The Security Group ID, required for access to the PostGres Database."

  validation {
    condition     = can(regex("^sg-[a-z0-9]{8,}$", var.database_access_security_group_id))
    error_message = "Invalid Security Group ID. It must start with 'sg-' followed by at least 8 alphanumeric characters."
  }
}

# ============================= #
#   Thunderdome Configuration   #
# ============================= #

variable "thunderdome_administrator_email" {
  type        = string
  description = "(Required) The email address of the initial user, to be assigned as the Thunderdome Administrator."
}


# ========================== #
#   Route 53 Configuration   #
# ========================== #

variable "hosted_zone_id" {
  type        = string
  description = "(Required) The Hosted Zone ID for the Hosted Zone to which the application's DNS will be added to."
}