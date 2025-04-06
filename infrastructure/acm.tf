resource "aws_acm_certificate" "prod_app_cert" {
  provider                  = aws.us_east_1
  domain_name               = var.app_domain
  subject_alternative_names = var.app_additional_domains
  validation_method         = "DNS"
}
