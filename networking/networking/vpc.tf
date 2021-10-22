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


resource "aws_flow_log" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  iam_role_arn    = "<iam_role_arn>"
  log_destination = "${aws_s3_bucket.this.arn}"
  traffic_type    = "ALL"

  tags = {
    GeneratedBy      = "Accurics"
    ParentResourceId = "aws_vpc.this"
  }
}
resource "aws_s3_bucket" "this" {
  bucket        = "this_flow_log_s3_bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled    = true
    mfa_delete = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_policy" "this" {
  bucket = "${aws_s3_bucket.this.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "this-restrict-access-to-users-or-roles",
      "Effect": "Allow",
      "Principal": [
        {
          "AWS": [
            <principal_arn>
          ]
        }
      ],
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
    }
  ]
}
POLICY
}