data "aws_route53_zone" "primary" {
  filter {
    name   = "name"
    values = ["swapstamp.com."]  # note the trailing dot
  }
  private_zone = false
}