resource "aws_s3_bucket" "website_bucket" {
  bucket        = "swapstamp-webapp-${var.domain_name}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "website_bucket_acl" {
  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

locals {
  # Costruiamo manualmente l'endpoint S3 in modalità website. Notare che la sintassi
  # è valida per regioni diverse da us-east-1; per us-east-1 l'endpoint potrebbe variare.
  s3_website_endpoint = "${aws_s3_bucket.website_bucket.id}.s3-website-${var.region}.amazonaws.com"
}
