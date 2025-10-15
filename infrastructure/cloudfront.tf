resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.website_endpoint
    origin_id   = "S3-${aws_s3_bucket.website_bucket.id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"
  aliases             = ["app.${var.domain_name}"]

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.website_bucket.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Swapstamp App Distribution"
  }
}

# APP: app.swapstamp.com
resource "aws_cloudfront_distribution" "new_static" {
  enabled             = true
  default_root_object = "index.html"

  # 👇 make this the app hostname
  aliases = ["app.${var.domain_name}"]

  origin {
    # 👇 point to the NEW bucket's S3 website endpoint
    domain_name = aws_s3_bucket.website_new_bucket.website_endpoint
    origin_id   = "S3-app-website-new"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    # 👇 must match origin_id above
    target_origin_id       = "S3-app-website-new"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn  # wildcard *.swapstamp.com
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = { Name = "Swapstamp App Distribution" }
}