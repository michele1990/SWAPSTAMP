output "cloudfront_domain" {
  description = "The CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.distribution.domain_name
}
