data "aws_route53_zone" "domain" {
  name         = local.root_domain
  private_zone = false
}

resource "aws_route53_record" "accessible_domain" {
  for_each = {
    for dvo in aws_acm_certificate.accessible_domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
  zone_id         = data.aws_route53_zone.domain.zone_id
}

resource "aws_route53_record" "distribution_domain_mapping" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_application.domain_name
    zone_id                = aws_cloudfront_distribution.web_application.hosted_zone_id
    evaluate_target_health = false
  }
}

// www subdomain
resource "aws_route53_record" "www_subdomain" {
  count = var.needs_www_redirect ? 1 : 0

  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "www.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_route53_record.distribution_domain_mapping.fqdn]
}