output "kube2iam_iam_role_arn" {
  description = "kube2iam IAM role name for EKS worker groups"
  value = module.eks.kube2iam_iam_role_arn
}

output "worker_iam_role_arn" {
  description = "worker IAM role name for EKS worker groups"
  value = module.eks.worker_iam_role_arn
}

output "kube2iam_policy" {
  description = "kube2iam IAM policy name for EKS worker groups"
  value = module.eks.kube2iam_iam_policy_arn
}

output "alb_security_group_id" {
  description = "kube2iam IAM policy name for EKS worker groups"
  value = aws_security_group.this.id
}

output "eks_temp_dir" {
  value = module.eks.temp_dir
}

output "efs_arn" {
  value = module.eks.efs_arn
}

output "efs_sg_arn" {
  value = module.eks.efs_sg_arn
}
