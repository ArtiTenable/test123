module "vpc" {
  source = "../networking"

  name        = var.vpc_name
  subnet_name = var.environment
  cidr        = var.vpc_cidr

  azs = var.az_list

  private_subnets = var.private_subnet_list
  public_subnets  = var.public_subnet_list

  enable_nat_gateway   = "true"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_s3_endpoint   = "true"

  tags = {
    terraform_managed = "true"
    Environment       = var.environment
    CostCenter        = "207"
    Stack             = var.environment
  }
}

