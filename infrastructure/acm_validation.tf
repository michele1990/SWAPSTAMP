locals {
  # Convert the set of validation options into a list of objects
  cert_dvos_list = [
    for dvo in aws_acm_certificate.certificate.domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ]
  # Group by record name. If duplicates exist, they are collected as a list.
  unique_cert_dvos = { for dvo in local.cert_dvos_list : dvo.name => dvo ... }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.unique_cert_dvos
  zone_id  = data.aws_route53_zone.primary.zone_id
  name     = each.key
  type     = each.value[0].type      # Use the first element from the group
  records  = [ each.value[0].value ]  # Use the first element's value
  ttl      = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for rec in aws_route53_record.cert_validation : rec.fqdn]
}
