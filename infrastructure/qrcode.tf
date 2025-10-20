# Subdomain fisso per i QR
locals {
  qr_fqdn = "qr.swapstamp.com"

  # Nomi bucket "hardcoded" e univoci (cambiali se li vuoi diversi)
  qr_site_bucket_name = "swapstamp-qr-website-20251020"
  qr_logs_bucket_name = "swapstamp-cf-logs-20251020"
}



############################
# Bucket S3 website per QR #
############################
resource "aws_s3_bucket" "qr_site" {
  bucket        = local.qr_site_bucket_name
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = { Name = "QR Website" }
}

# Per usare l’endpoint "website" con CloudFront, serve il bucket pubblico (solo GET)
resource "aws_s3_bucket_public_access_block" "qr_site_pab" {
  bucket = aws_s3_bucket.qr_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "qr_site_policy" {
  bucket = aws_s3_bucket.qr_site.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.qr_site.arn}/*"
    }]
  })
}

##############################
# Bucket S3 per i log (CF)   #
##############################
resource "aws_s3_bucket" "qr_logs" {
  bucket        = local.qr_logs_bucket_name
  force_destroy = true
  # rimuovi o commenta la riga tags
  # tags = { Name = "CloudFront Logs (QR)" }
}

# (Consigliato) Ownership controls + ACL per compatibilità logging
resource "aws_s3_bucket_ownership_controls" "qr_logs_own" {
  bucket = aws_s3_bucket.qr_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "qr_logs_acl" {
  bucket = aws_s3_bucket.qr_logs.id
  acl    = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.qr_logs_own]
}

# Lifecycle: tieni i log 30 giorni (cambia a piacere)
resource "aws_s3_bucket_lifecycle_configuration" "qr_logs_lifecycle" {
  bucket = aws_s3_bucket.qr_logs.id
  rule {
    id     = "expire-logs-30d"
    status = "Enabled"
    expiration { days = 30 }
  }
}

resource "aws_cloudfront_distribution" "qr" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = [ local.qr_fqdn ]

  # Origin = S3 static website endpoint (pubblico)
  origin {
    domain_name = aws_s3_bucket.qr_site.website_endpoint
    origin_id   = "S3Website-${aws_s3_bucket.qr_site.id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3Website-${aws_s3_bucket.qr_site.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    # forward query string per vederla nei log (cs-uri-query)
    forwarded_values {
      query_string = true
      cookies { forward = "none" }
    }

    compress = true
  }

  # SPA routing: qualunque 403/404 torna index.html (così /{unique-id} funziona)
  custom_error_response {
    error_code            = 403
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 0
  }
  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 0
  }

  # Logging abilitato -> S3 logs bucket
logging_config {
  # usa il domain name "globale" (…s3.amazonaws.com), non quello regionale
  bucket          = aws_s3_bucket.qr_logs.bucket_domain_name
  prefix          = "qr/"
  include_cookies = false
}

  # Classe economica
  price_class = "PriceClass_100"

  # Riusa il certificato ACM che già usi (wildcard *.swapstamp.com)
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = { Name = "qr.swapstamp.com" }
}

resource "aws_route53_record" "qr_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = local.qr_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.qr.domain_name
    zone_id                = aws_cloudfront_distribution.qr.hosted_zone_id
    evaluate_target_health = false
  }

  allow_overwrite = true
}

output "qr_site_bucket" {
  value       = aws_s3_bucket.qr_site.bucket
  description = "S3 bucket name for the QR website"
}

output "qr_logs_bucket" {
  value       = aws_s3_bucket.qr_logs.bucket
  description = "S3 bucket name for CloudFront logs"
}

output "qr_domain" {
  value       = local.qr_fqdn
  description = "QR subdomain"
}

output "qr_cloudfront_domain" {
  value       = aws_cloudfront_distribution.qr.domain_name
  description = "CloudFront domain for QR"
}

# Consenti al servizio CloudFront Logs di scrivere nel bucket
resource "aws_s3_bucket_policy" "qr_logs_policy" {
  bucket = aws_s3_bucket.qr_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AWSCloudFrontLogsPutObject",
        Effect   = "Allow",
        Principal = { Service = "delivery.logs.amazonaws.com" },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.qr_logs.arn}/qr/*",
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Sid      = "AWSCloudFrontLogsGetBucketAcl",
        Effect   = "Allow",
        Principal = { Service = "delivery.logs.amazonaws.com" },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.qr_logs.arn
      }
    ]
  })
}