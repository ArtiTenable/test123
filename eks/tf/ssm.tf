resource "aws_ssm_parameter" "eks_sg" {
  name  = "${local.ssm_prefix}/eks_default_sg"
  type  = "String"
  value = aws_security_group.this.id
}

resource "aws_ssm_parameter" "kube2iam_default_role" {
  name  = "${local.ssm_prefix}/kube2iam_default_role"
  type  = "String"
  value = module.eks.kube2iam_iam_role_arn
}

resource "aws_ssm_parameter" "cluster_name" {
  name  = "${local.ssm_prefix}/cluster_name"
  type  = "String"
  value = local.cluster_name
}

resource "aws_ssm_parameter" "efs_id" {
  name  = "${local.ssm_prefix}/efs_id"
  type  = "String"
  value = module.eks.efs_id
}

resource "aws_ssm_parameter" "efs_dns" {
  name  = "${local.ssm_prefix}/efs_dns"
  type  = "String"
  value = module.eks.efs_dns
}

