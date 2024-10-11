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

# ======= #
#   ECS   #
# ======= #

variable "ecs_cluster_arn" {
  type        = string
  description = "(Required) The ARN of the ECS Cluster in which to deploy our ECS service and containers to."

  validation {
    condition     = can(regex("^arn:*:ecs:*:[0-9]{12}:cluster/*", var.ecs_cluster_arn))
    error_message = "Invalid ARN for ecs_cluster_arn. It should look something like: arn:<Your AWS Partition>:ecs:<AWS Region>:<Account ID>:cluster/<Cluster Name>"
  }
}