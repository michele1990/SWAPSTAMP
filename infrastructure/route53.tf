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

resource "aws_route53_record" "ses_domain_verification" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = 300

  records = [
    "4hho8Q8Bn9GdJ3zxYl86lE/9ij0/Yr3n132unW5PmAA="
  ]
}

resource "aws_route53_record" "ses_dkim" {
  for_each = {
    "sbg4rga3zr7werzzmhchm3w2icorvkic" = "sbg4rga3zr7werzzmhchm3w2icorvkic.dkim.amazonses.com"
    "th3lmimsfvufqdfpwuvxh4lt7yljmxlk" = "th3lmimsfvufqdfpwuvxh4lt7yljmxlk.dkim.amazonses.com"
    "vdwztxu4wcnju57p2uwnaqwovtwd3mv5" = "vdwztxu4wcnju57p2uwnaqwovtwd3mv5.dkim.amazonses.com"
  }

  zone_id = aws_route53_zone.primary.zone_id
  name    = "${each.key}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300

  records = [
    each.value
  ]
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
