data "aws_route53_zone" "primary" {
  name         = "swapstamp.com."   # note: trailing dot is required
  private_zone = false
}