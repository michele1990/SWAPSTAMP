output "nameservers" {
  description = "Nameservers for the Route53 hosted zone. Update your registrar with these values."
  value       = aws_route53_zone.primary.name_servers
}

output "s3_bucket_name" {
  description = "The S3 bucket used for website hosting."
  value       = aws_s3_bucket.website_bucket.bucket
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}
