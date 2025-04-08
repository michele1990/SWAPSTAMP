############## Hosted Zone ##############
# If an existing zone ID is provided, use it via a data block.
data "aws_route53_zone" "existing_zone" {
  count   = var.existing_zone_id != "" ? 1 : 0
  zone_id = var.existing_zone_id
}

# If no existing zone ID is provided, create a new public hosted zone.
resource "aws_route53_zone" "zone" {
  count   = var.existing_zone_id == "" ? 1 : 0
  name    = var.root_domain
  comment = "Managed by Terraform"
}

# Define a local variable to reference the zone ID regardless of the source.
locals {
  zone_id = var.existing_zone_id != "" ? var.existing_zone_id : aws_route53_zone.zone[0].zone_id
}

############## Certificate Validation Records ##############
# Deduplicate certificate DNS validation records if duplicates exist.
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
  zone_id  = local.zone_id
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
