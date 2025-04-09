output "nameservers" {
  description = "Nameservers for the Route53 hosted zone. Update your registrar with these values if needed."
  value       = [
    "ns-1838.awsdns-37.co.uk",
    "ns-189.awsdns-23.com",
    "ns-560.awsdns-06.net",
    "ns-1134.awsdns-13.org"
  ]
}

output "s3_bucket_name" {
  description = "The S3 bucket used for website hosting."
  value       = aws_s3_bucket.website_bucket.bucket
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate."
  value       = aws_acm_certificate.certificate.arn
}
