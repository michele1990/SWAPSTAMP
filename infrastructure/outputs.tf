output "cloudfront_domain" {
  description = "The CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "website_cloudfront_domain" {
  description = "The CloudFront distribution domain name for the main website (swapstamp.com/www)."
  value       = aws_cloudfront_distribution.website.domain_name
}

