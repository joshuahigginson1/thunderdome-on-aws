# Configures a Route 53 Entry and valid certificate for the Load Balancer attached to Thunderdome Server.

locals {
  # NB: Change this name for each application deployed using this template.
  subdomain = "thunderdome"
}

# =============== #
#   Certificate   #
# =============== #

resource "aws_acm_certificate" "lb_certificate" {
  domain_name               = "${local.subdomain}.${data.aws_route53_zone.current.name}"
  subject_alternative_names = ["www.${local.subdomain}.${data.aws_route53_zone.current.name}"]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "lb_certificate_validation" {
  certificate_arn         = aws_acm_certificate.lb_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.dvo_entries : record.fqdn]
}

# =============== #
#   DNS Records   #
# =============== #

# ---------------------------------- #
#   Certificate Validation Entries   #
# ---------------------------------- #

resource "aws_route53_record" "dvo_entries" {
  for_each = {
    for dvo in aws_acm_certificate.lb_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}


# ----------------------- #
#   Application Entries   #
# ----------------------- #

# DNS Record Entries for the application itself.

resource "aws_route53_record" "application_entry" {

  zone_id = var.hosted_zone_id
  name    = "${local.subdomain}.${data.aws_route53_zone.current.name}"
  type    = "A"

  alias {
    name                   = aws_lb.public_alb.dns_name
    zone_id                = aws_lb.public_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_application_entry" {

  zone_id = var.hosted_zone_id
  name    = "www.${local.subdomain}.${data.aws_route53_zone.current.name}"
  type    = "A"

  alias {
    name                   = aws_lb.public_alb.dns_name
    zone_id                = aws_lb.public_alb.zone_id
    evaluate_target_health = true
  }
}