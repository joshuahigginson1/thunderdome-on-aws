# ----------------------- #
#   Deletion Protection   #
# ----------------------- #

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Enables deletion protection for all deployed resources. When set to 'true', resources cannot be deleted directly via the AWS Console or API, safeguarding against accidental deletion. Defaults to 'false'."
}

check "deletion_protection_warning" {
  assert {
    condition     = var.deletion_protection
    error_message = <<EOT
⚠ WARNING: Deletion protection is currently set to 'false'.

This configuration allows for the easy deletion and clean up of Thunderdome, which may be
suitable for development or testing environments. For deploying Thunderdome to production,
it is strongly recommended to enable deletion protection, by setting this variable to 'true'.

This will prevent accidental deletions of key resources such as the Thunderdome PostGres database.

Please review and adjust this setting as needed for your specific use case.
EOT
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