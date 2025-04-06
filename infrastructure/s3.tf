### s3.tf

resource "aws_s3_bucket" "prod_app_bucket" {
  bucket = var.s3_bucket_name
  acl    = var.s3_bucket_acl

  website {
    index_document = var.index_document
    error_document = var.error_document
  }

  tags = {
    Name       = var.s3_bucket_tag_name
    Created_By = var.created_by
  }
}

resource "aws_s3_bucket_policy" "prod_app_policy" {
  bucket = aws_s3_bucket.prod_app_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "arn:aws:s3:::${aws_s3_bucket.prod_app_bucket.bucket}/*"
    }]
  })
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.prod_app_bucket.id
  key          = var.index_document
  source       = var.index_html_source
  content_type = "text/html"
  etag         = filemd5(var.index_html_source)
}


### acm.tf

resource "aws_acm_certificate" "prod_app_cert" {
  provider                  = aws.us_east_1
  domain_name               = var.app_domain
  subject_alternative_names = var.app_additional_domains
  validation_method         = "DNS"
}