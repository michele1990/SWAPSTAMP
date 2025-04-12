variable "domain_name" {
  description = "The root domain for the site."
  type        = string
  default     = "swapstamp.com"
}

variable "region" {
  description = "AWS region for primary resources."
  type        = string
  default     = "eu-west-3"
}

variable "hosted_zone_id" {
  description = "The Route53 Hosted Zone ID for the domain."
  type        = string
}
