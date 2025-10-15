resource "aws_cloudfront_distribution" "redirect" {
  enabled             = true
  default_root_object = "index.html" # ignored; S3 website performs redirect

  aliases = [local.redirect_fqdn]  # e.g., go.swapstamp.com

  origin {
    domain_name = aws_s3_bucket.redirect_bucket.website_endpoint
    origin_id   = "S3-redirect-${aws_s3_bucket.redirect_bucket.id}"

    # S3 website endpoints require custom_origin_config (not s3_origin_config)
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-redirect-${aws_s3_bucket.redirect_bucket.id}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    forwarded_values {
      query_string = true
      cookies { forward = "none" }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn  # from your acm.tf (wildcard covers this)
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = { Name = "Swapstamp Redirect Distribution (${local.redirect_fqdn})" }
}