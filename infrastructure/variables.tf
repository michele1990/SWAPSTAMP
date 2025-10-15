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

# Subdomain that will redirect to app.swapstamp.com
variable "redirect_subdomain" {
  description = "Subdomain that will 301-redirect to app.swapstamp.com"
  type        = string
  default     = "go" # change to what you want (e.g., "admin", "start", "docs")
}

locals {
  redirect_fqdn = "${var.redirect_subdomain}.${var.domain_name}" # e.g., go.swapstamp.com
}