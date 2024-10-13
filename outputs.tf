# ================== #
#   Custom Outputs   #
# ================== #

# Custom Outputs often change from deployment to deployment, and warrant editing.

output "server_fqdn" {
  description = "The fully qualified domain name at which Thunderdome is now hosted at."
  value       = module.thunderdome_server.server_fqdn
}