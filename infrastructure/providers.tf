provider "aws" {
  region = var.aws_region
}

# ACM certificates for CloudFront must be created in us-east-1.
provider "aws" {
  alias  = "us_east_1"
  region = var.aws_region_cert
}
