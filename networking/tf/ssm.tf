resource "aws_ssm_parameter" "private_subnets" {
  name  = "${local.ssm_prefix}/private_subnets"
  type  = "String"
  value = join(",", module.vpc.private_subnets)
}

resource "aws_ssm_parameter" "private_subnets_individual" {
  count = length(var.private_subnet_list)
  name  = "${local.ssm_prefix}/private_subnets_${count.index}"
  type  = "String"
  value = module.vpc.private_subnets[count.index]
}

resource "aws_ssm_parameter" "public_subnets" {
  name  = "${local.ssm_prefix}/public_subnets"
  type  = "String"
  value = join(",", module.vpc.public_subnets)
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name  = "${local.ssm_prefix}/vpc_cidr"
  type  = "String"
  value = module.vpc.vpc_cidr_block
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "${local.ssm_prefix}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "natgw_ips" {
  name  = "${local.ssm_prefix}/natgw_ips"
  type  = "String"
  value = join(",", module.vpc.nat_public_ips)
}
