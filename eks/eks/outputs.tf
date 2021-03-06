output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "efs_id" {
  description = "The name/id of EFS"
  value       = aws_efs_file_system.this.id
}

output "efs_dns" {
  description = "The DNS of EFS"
  value       = aws_efs_file_system.this.dns_name
}

output "efs_arn" {
  description = "The ARN of EFS"
  value       = aws_efs_file_system.this.arn
}

# Though documented, not yet supported
# output "cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster."
#   value       = "${aws_eks_cluster.this.arn}"
# }

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = local.cluster_security_group_id
}

output "efs_sg_arn" {
  description = "EFS's security group ARN"
  value       = aws_security_group.efs.arn
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = data.template_file.config_map_aws_auth.rendered
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = data.template_file.kubeconfig.rendered
}

output "workers_asg_arns" {
  description = "IDs of the autoscaling groups containing workers."
  value       = aws_autoscaling_group.workers.*.arn
}

output "workers_asg_names" {
  description = "Names of the autoscaling groups containing workers."
  value       = aws_autoscaling_group.workers.*.id
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = local.worker_security_group_id
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = aws_iam_role.workers.name
}

output "kube2iam_iam_role_arn" {
  description = "kube2iam IAM role name for EKS worker groups"
  value       = aws_iam_role.kube2iam.arn
}

output "kube2iam_iam_policy_arn" {
  description = "kube2iam IAM policy name for EKS worker groups"
  value       = aws_iam_policy.kube2iam.arn
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = aws_iam_role.workers.arn
}
