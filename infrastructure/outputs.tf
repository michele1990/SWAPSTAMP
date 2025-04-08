output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.prod_app_bucket.bucket
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.prod_app_distribution.domain_name
}

output "route53_nameservers" {
  description = "Nameservers for Route53 zone"
  value       = var.existing_zone_id != "" ? data.aws_route53_zone.existing_zone[0].name_servers : aws_route53_zone.zone[0].name_servers
}
