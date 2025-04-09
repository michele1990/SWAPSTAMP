locals {
  # Convert the set of validation options to a list so that we can index it.
  cert_dvos = [for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo]
}

# Create DNS records for certificate validation in the hosted zone.
resource "aws_route53_record" "cert_validation" {
  # Hardcode the count to 3 (apex, www, and wildcard) assuming these are the three records returned.
  count   = 3
  zone_id = aws_route53_zone.primary.zone_id
  name    = local.cert_dvos[count.index].resource_record_name
  type    = local.cert_dvos[count.index].resource_record_type
  records = [local.cert_dvos[count.index].resource_record_value]
  ttl     = 60
}

# Validate the ACM certificate once the DNS records are in place.
resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
