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

resource "aws_route53_record" "google_site_verification" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name # "@" / blank in Zoho docs = apex = swapstamp.com
  type    = "TXT"
  ttl     = 300

  records = [
    "google-site-verification=iMiijcnQJt5qHK-9VEbLtKUcT7zzWarTYcu-rpVC0vI",
    "google-site-verification=M3TAmjYCvmzhzOvi2YJMGLEHVbkCX6-Uc1appeg8NTs",
    "zoho-verification=zb92663460.zmverify.zoho.eu",
    "v=spf1 include:zohomail.eu ~all"
  ]

  allow_overwrite = true
}

resource "aws_route53_record" "zoho_mx" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 300

  records = [
    "10 mx.zoho.eu",
    "20 mx2.zoho.eu",
    "50 mx3.zoho.eu",
  ]

  allow_overwrite = true
}

resource "aws_route53_record" "zoho_dkim" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "zmail._domainkey.${var.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCJuuov4RfgKFZjvgZoB3/AY+5RXMzdE7RlOCCVzPGIMxvRgbWqeYst/BmEY/jz+AgTxfOzqMvom/NKs2zn5tvRFZtma7GNeWYk5h2ZosjoM7iMF3DI+Ze3Qw79YnDeXnk7j5xdsseYyVwY2G3OT05/ZaMqEZciBhPPdoEgYVhzQIDAQAB"
  ]

  allow_overwrite = true
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=none; rua=mailto:mafe@swapstamp.com; adkim=r; aspf=r; pct=100"
  ]

  allow_overwrite = true
}


# DNS A/ALIAS for the new subdomain → CloudFront
resource "aws_route53_record" "website_new_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = local.new_static_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.new_static.domain_name
    zone_id                = aws_cloudfront_distribution.new_static.hosted_zone_id
    evaluate_target_health = false
  }
}
