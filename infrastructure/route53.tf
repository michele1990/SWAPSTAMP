resource "aws_route53_record" "app_alias_apex" {
  zone_id = local.zone_id
  name    = var.root_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.prod_app_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.prod_app_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app_alias_wildcard" {
  zone_id = local.zone_id
  name    = "*.${var.root_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.prod_app_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.prod_app_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
