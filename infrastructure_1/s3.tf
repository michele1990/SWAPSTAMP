# Create a private S3 bucket to host the “under construction” page.
resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.domain_name}-website"
  acl    = "private"

  tags = {
    Name = "Website Bucket for ${var.domain_name}"
  }
}

# Set up a website configuration (CloudFront will front this bucket).
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Upload the index.html file (ensure that an index.html exists locally in the same directory).
resource "aws_s3_bucket_object" "index" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  acl          = "private"
}

# Create an Origin Access Identity so CloudFront can securely access the S3 bucket.
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name} website"
}

# Bucket policy allowing CloudFront (OAI) to read objects from the bucket.
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontRead",
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}
