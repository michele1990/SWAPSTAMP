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

variable "new_static_subdomain" {
  description = "Subdomain for the new static website"
  type        = string
  default     = "docs"
}

locals {
  new_static_fqdn = "${var.new_static_subdomain}.${var.domain_name}"
}