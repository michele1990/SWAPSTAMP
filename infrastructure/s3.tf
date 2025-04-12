resource "aws_s3_bucket" "website_bucket" {
  # Il nome include "swapstamp-webapp" per garantire la sua unicità
  bucket = "swapstamp-webapp-${var.domain_name}"
  acl    = "public-read"
  
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  
  force_destroy = true
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}
