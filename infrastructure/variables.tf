variable "domain_name" {
  description = "The primary domain (e.g., swapstamp.com)"
  type        = string
  default     = "swapstamp.com"
}

variable "region" {
  description = "AWS region for primary resources"
  type        = string
  default     = "eu-west-3"
}
