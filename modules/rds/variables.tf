# =========== #
#   General   #
# =========== #

# ----------------------- #
#   Deletion Protection   #
# ----------------------- #

variable "deletion_protection" {
  type        = bool
  description = "(Required) Enables deletion protection for the RDS Deployment. When set to 'true', resources cannot be deleted directly via the AWS Console or API, safeguarding against accidental deletion."
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
  description = "(Required) The VPC ID in which to deploy our underlying RDS Database into."

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


# ====================== #
#   Database Specifics   #
# ====================== #

variable "initial_database_name" {
  description = "(Required) The name of the first 'database' name, as defined in either PostGres or MySQL."
  type        = string

  validation {
    condition     = can(regex("^[a-z_]+$", var.initial_database_name))
    error_message = "The initial database name must only contain lowercase letters and underscores, conforming to lower_camel_case style."
  }


  validation {
    condition     = length(var.initial_database_name) > 2
    error_message = "Your database name should really exceed two characters in length..."
  }

  validation {
    condition     = length(var.initial_database_name) <= 63
    error_message = "The initial database name must not exceed 63 characters, which is the maximum length for both PostgreSQL and MySQL hosted on AWS."
  }
}

variable "database_engine" {
  type        = string
  description = "The underlying database engine which backs RDS Aurora Serverless v2. Either 'postgresql' or 'mysql'. Defaults to 'postgres'."

  validation {
    condition     = contains(["postgresql", "mysql"], var.database_engine)
    error_message = "The two valid values for database_engine are either 'postgresql' or 'mysql'."
  }
}
