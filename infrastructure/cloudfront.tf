resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.website_endpoint
    origin_id   = "S3-${aws_s3_bucket.website_bucket.id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [
    var.domain_name,
    "www.${var.domain_name}"
  ]

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.website_bucket.id}"
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"  # classe di prezzo minima

  # Per ora si usa il certificato default di CloudFront; il certificato custom HTTPS verrà aggiunto successivamente.
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Swapstamp Webapp Distribution"
  }
}
