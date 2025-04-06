resource "aws_cloudfront_distribution" "prod_app_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document

  # Accept both the primary and additional domains.
  aliases = concat([var.app_domain], var.app_additional_domains)

  origin {
    domain_name = aws_s3_bucket.prod_app_bucket.website_endpoint
    origin_id   = "S3ProdAppOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3ProdAppOrigin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.prod_app_cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.cloudfront_tag_name
  }
}
