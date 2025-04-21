resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website_main_bucket.website_endpoint
    origin_id   = "S3-main-${aws_s3_bucket.website_main_bucket.id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"
  aliases             = [
    var.domain_name,          # swapstamp.com
    "www.${var.domain_name}", # www.swapstamp.com
  ]

  default_cache_behavior {
    target_origin_id       = "S3-main-${aws_s3_bucket.website_main_bucket.id}"
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
    Name = "Swapstamp Main Website"
  }
}
