resource "aws_acm_certificate" "certificate" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = [
    "www.${var.domain_name}",
    "*.${var.domain_name}"
  ]
  validation_method         = "DNS"

  lifecycle {
    # Once the certificate is issued, we ignore changes in the computed validation options.
    ignore_changes = [domain_validation_options]
  }
}
