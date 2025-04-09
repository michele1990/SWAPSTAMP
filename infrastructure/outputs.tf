output "certificate_arn" {
  description = "The ARN of the ACM certificate."
  value       = aws_acm_certificate.certificate.arn
}

output "certificate_domain_validation_options" {
  description = "The domain validation options for the certificate."
  value       = aws_acm_certificate.certificate.domain_validation_options
}

output "zone_nameservers" {
  description = "Nameservers for the Route53 hosted zone. Update your registrar with these values."
  value       = aws_route53_zone.primary.name_servers
}
