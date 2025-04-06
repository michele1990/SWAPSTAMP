resource "aws_acm_certificate" "hello_world_cert" {
  provider          = aws.us_east_1
  domain_name       = var.cloudfront_domain
  validation_method = "DNS"
}
