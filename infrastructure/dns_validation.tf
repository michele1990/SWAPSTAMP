resource "aws_route53_zone" "zone" {
  name = var.root_domain
}

locals {
  unique_validation_options = {
    for key, group in {
      for dvo in aws_acm_certificate.prod_app_cert.domain_validation_options :
      dvo.resource_record_name => {
        name  = dvo.resource_record_name
        type  = dvo.resource_record_type
        value = dvo.resource_record_value
      }...
    } : key => group[0]
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.unique_validation_options
  zone_id  = aws_route53_zone.zone.zone_id
  name     = each.value.name
  type     = each.value.type
  records  = [each.value.value]
  ttl      = var.route53_ttl
}

resource "aws_acm_certificate_validation" "prod_app_cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.prod_app_cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}
