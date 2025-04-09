# Request a certificate covering the apex domain and www (as a SAN)
resource "aws_acm_certificate" "certificate" {
  provider                  = aws.us_east_1
  domain_name               = "swaptamp.com"
  subject_alternative_names = ["www.swaptamp.com", "*.swaptamp.com"]
  validation_method         = "DNS"
}

# Create DNS records for validation in the hosted zone
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

# Validate the ACM certificate once DNS records are in place
resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
