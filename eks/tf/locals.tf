locals {
  ssm_prefix   = "/${var.environment}/${var.vpc_region}"
  cluster_name = "${var.environment}-${var.vpc_region}-eks"
}

