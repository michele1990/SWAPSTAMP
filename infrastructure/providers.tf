provider "aws" {
  region = var.region
}

# Resources that must be created in us-east-1 (ACM and CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
