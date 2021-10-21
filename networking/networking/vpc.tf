locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.elasticache_subnets),
    length(var.database_subnets),
    length(var.redshift_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
}

#---------------------------------------------------#  
# VPC
#---------------------------------------------------#  
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.vpc_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

#---------------------------------------------------#  
# Defaults
#---------------------------------------------------#  
resource "aws_default_vpc" "this" {
  count = var.manage_default_vpc ? 1 : 0

  enable_dns_support   = var.default_vpc_enable_dns_support
  enable_dns_hostnames = var.default_vpc_enable_dns_hostnames
  enable_classiclink   = var.default_vpc_enable_classiclink

  tags = merge(
    {
      "Name" = format("%s", var.default_vpc_name)
    },
    var.default_vpc_tags,
    var.tags,
  )
}

