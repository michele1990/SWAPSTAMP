# Create a Route 53 hosted zone for the domain.
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

# Apex domain alias (swapstamp.com) pointing to CloudFront.
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# www subdomain alias (www.swapstamp.com).
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Wildcard record for future subdomains (like api.swapstamp.com, stage.swapstamp.com, etc.).
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
