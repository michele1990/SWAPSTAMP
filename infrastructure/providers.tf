provider "aws" {
  region = var.region
}

# ACM and CloudFront must be created in us-east-1.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
