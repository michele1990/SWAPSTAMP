// s3.tf
// ──────────────────────────────────────────────────────────────────

# App bucket (app.swapstamp.com)
resource "aws_s3_bucket" "website_bucket" {
  bucket        = "swapstamp-webapp-${var.domain_name}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket_pab" {
  bucket = aws_s3_bucket.website_bucket.id

  # Ensure we can still put a public policy
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
    }]
  })
}


# Main website bucket (swapstamp.com + www.swapstamp.com)
resource "aws_s3_bucket" "website_main_bucket" {
  bucket        = "swapstamp-website-${var.domain_name}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website_main_bucket_pab" {
  bucket = aws_s3_bucket.website_main_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_main_bucket_policy" {
  bucket = aws_s3_bucket.website_main_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.website_main_bucket.arn}/*"
    }]
  })
}

# New static website bucket (e.g., docs.swapstamp.com)
resource "aws_s3_bucket" "website_new_bucket" {
  bucket        = "swapstamp-docs-static-xyz"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website_new_bucket_pab" {
  bucket = aws_s3_bucket.website_new_bucket.id

  # Allow public-read policy (same as your other sites)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_new_bucket_policy" {
  bucket = aws_s3_bucket.website_new_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.website_new_bucket.arn}/*"
    }]
  })
}