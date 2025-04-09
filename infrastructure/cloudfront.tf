resource "aws_cloudfront_distribution" "website_distribution" {
  depends_on = [aws_acm_certificate_validation.certificate_validation]
  enabled    = true
  is_ipv6_enabled = true
  comment    = "CloudFront distribution for ${var.domain_name}"
  default_root_object = "index.html"

  # List all aliases. A wildcard record is not supported as an alias in CloudFront,
  # so we list the apex and www. Additional domain records can be added via Route53.
  aliases = [
    var.domain_name,
    "www.${var.domain_name}"
  ]

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = "S3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
