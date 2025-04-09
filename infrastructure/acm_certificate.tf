# Request a certificate covering the apex domain, the www subdomain, and any subdomain via wildcard.
resource "aws_acm_certificate" "certificate" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = [
    "www.${var.domain_name}",
    "*.${var.domain_name}"
  ]
  validation_method         = "DNS"
}
