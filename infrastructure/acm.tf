resource "aws_acm_certificate" "cert" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name                # swapstamp.com
  subject_alternative_names = [
    "www.${var.domain_name}",               # www.swapstamp.com
    "*.${var.domain_name}",                 # *.swapstamp.com
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Unique set of the DNS validation record names
  record_names = toset([
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.resource_record_name
  ])
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.record_names

  zone_id = aws_route53_zone.primary.zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 60

  # Pick the one matching value for this name
  records = [
    element(
      [
        for dvo in aws_acm_certificate.cert.domain_validation_options :
        dvo.resource_record_value
        if dvo.resource_record_name == each.key
      ],
      0
    )
  ]
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for rec in aws_route53_record.cert_validation : rec.fqdn
  ]
}
