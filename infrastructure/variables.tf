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
