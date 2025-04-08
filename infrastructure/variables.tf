variable "aws_region" {
  description = "AWS region for S3 bucket and most resources"
  type        = string
  default     = "eu-west-3"
}

variable "aws_region_cert" {
  description = "AWS region for ACM certificate (must be us-east-1 for CloudFront)"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Unique name for the S3 bucket hosting the production app"
  type        = string
  default     = "prod-app-static-hosting-unique"
}

variable "s3_bucket_acl" {
  description = "ACL for the S3 bucket"
  type        = string
  default     = "public-read"
}

variable "s3_bucket_tag_name" {
  description = "Tag for the S3 bucket"
  type        = string
  default     = "ProdAppStaticHosting"
}

variable "created_by" {
  description = "Creator tag for the resources"
  type        = string
  default     = "DevOps"
}

variable "index_document" {
  description = "The index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The error document for the website"
  type        = string
  default     = "error.html"
}

variable "index_html_source" {
  description = "Local path to your index HTML file"
  type        = string
  default     = "index.html"
}

variable "app_domain" {
  description = "Primary domain for the production app (e.g. swapstamp.com)"
  type        = string
  default     = "swapstamp.com"
}

variable "app_additional_domains" {
  description = "Additional domains (e.g. www.swapstamp.com, api.swapstamp.com, etc.)"
  type        = list(string)
  default     = ["www.swapstamp.com"]
}

variable "root_domain" {
  description = "The root domain for Route53"
  type        = string
  default     = "swapstamp.com"
}

variable "route53_ttl" {
  description = "TTL for Route53 records"
  type        = number
  default     = 60
}

variable "cloudfront_tag_name" {
  description = "Tag for the CloudFront distribution"
  type        = string
  default     = "ProdAppCloudFront"
}
