output "cloudfront_domain" {
  description = "The CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "website_cloudfront_domain" {
  description = "The CloudFront distribution domain name for the main website (swapstamp.com/www)."
  value       = aws_cloudfront_distribution.website.domain_name
}

output "redirect_site_fqdn" {
  value       = local.redirect_fqdn
  description = "New redirect site domain"
}

output "redirect_cloudfront_domain" {
  value       = aws_cloudfront_distribution.redirect.domain_name
  description = "CloudFront domain backing the redirect site"
}