### s3.tf

resource "aws_s3_bucket" "prod_app_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name       = var.s3_bucket_tag_name
    Created_By = var.created_by
  }
}

# Set static website configuration separately
resource "aws_s3_bucket_website_configuration" "prod_app_website" {
  bucket = aws_s3_bucket.prod_app_bucket.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# Optional (but required for legacy-style public read — NOT recommended in new AWS standards)
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.prod_app_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

