# =========== #
#   General   #
# =========== #

# ----------------------- #
#   Deletion Protection   #
# ----------------------- #

# variable "deletion_protection" {
#   type        = bool
#   description = "(Required) Enables deletion protection for the Network Resources. When set to 'true', resources cannot be deleted directly via the AWS Console or API, safeguarding against accidental deletion."
# }


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


# ============== #
#   Networking   #
# ============== #

variable "max_subnets" {
  type        = number
  description = "(Required) The maximum number of Subnets to create within this VPC. Must be between 1 and 6."

  validation {
    condition     = var.max_subnets > 0
    error_message = "The max_subnets value must be greater than 0. Obviously..."
  }

  validation {
    condition     = var.max_subnets <= 6
    error_message = "The max_subnets value must be less than or equal to 6, which is the the maximum number of Availability Zones in any AWS region."
  }

  validation {
    condition     = floor(var.max_subnets) == var.max_subnets
    error_message = "The max_subnets value must be a whole number."
  }
}