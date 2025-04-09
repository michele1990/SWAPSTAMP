# Create a Route 53 hosted zone for the domain.
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}
