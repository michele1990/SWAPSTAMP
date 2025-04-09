resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.domain_name}-website"
  acl    = "private"

  tags = {
    Name = "Website Bucket for ${var.domain_name}"
  }
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  acl          = "private"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name} website"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontRead",
        Effect    = "Allow",
        Principal = { AWS = aws_cloudfront_origin_access_identity.oai.iam_arn },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}
