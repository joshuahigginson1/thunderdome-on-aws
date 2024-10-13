data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_route53_zone" "current" {
  # Gets the APEX Domain / Existing Subdomain attributed to the provided Hosted Zone ID.
  zone_id = var.hosted_zone_id
}