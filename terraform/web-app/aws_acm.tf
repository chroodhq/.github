resource "aws_acm_certificate" "accessible_domain" {
  provider = aws.virginia

  domain_name               = var.domain
  subject_alternative_names = var.needs_www_redirect ? ["www.${var.domain}"] : []
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "accessible_domain" {
  provider = aws.virginia

  certificate_arn         = aws_acm_certificate.accessible_domain.arn
  validation_record_fqdns = [for record in aws_route53_record.accessible_domain : record.fqdn]
}