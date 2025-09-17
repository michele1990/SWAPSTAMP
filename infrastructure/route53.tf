resource "aws_route53_zone" "primary" {
  name    = var.domain_name
  comment = "Managed by Terraform"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "app_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "app.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# route53-website.tf
resource "aws_route53_record" "apex_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# Verifica Google Search Console (Domain property)
resource "aws_route53_record" "google_site_verification" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name         # es. "swapstamp.com"
  type    = "TXT"
  ttl     = 300
  records = ["\"google-site-verification=iMiijcnQJt5qHK-9VEbLtKUcT7zzWarTYcu-rpVC0vI\""]
  allow_overwrite = true
}