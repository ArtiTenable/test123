terraform {
  backend "s3" {}
}

provider "aws" {
  max_retries            = "5"
  profile                = "default"
  region                 = "eu-west-1"
  skip_get_ec2_platforms = true
  skip_region_validation = true
}
