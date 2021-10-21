resource "aws_key_pair" "eks" {
  key_name   = "${var.environment}-${var.vpc_region}-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4o6tXxGnDMgsrxA2A8kxGgTI3Jxh/BOoXO5ZWqAkJJnOD82/kGiV0S3D4saN0oOS2qR5RxnGKP7clJK/5fgOSibYJGm3DLLqm4w1ZbvLiQT6LOiyaGFDGnlpnQzGmIcptH2KWNU9smFNiS/vnouhwQhBnIGkMfWlXaylMq07YpyTcBHbjqygaDtJBKPQCKOTy+Zjz4UeGTN5Vu0tqImFU7XCL8Z7ZFWZnkGGqVBnBR6UvirMCFqnsIZqjwZQD+T6cv7CQVXJyDLVao3ioujsHruvGwfuNcJd5UO+vvcBReKFywjDwzq/ucv+gjXFlpbYRUto4uVwHmjQnh8m3cuI3 root@aa"
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_ami_version}"]
  }

  owners      = ["602401143452"] # Amazon
}

locals {
  worker_groups = [
    {
      name                 = "k8s-worker-green"
      asg_max_size         = var.green_asg_max_size
      asg_desired_capacity = var.green_asg_desired_capacity
      asg_min_size         = var.green_asg_min_size
      instance_type        = var.green_instance_type
      key_name             = aws_key_pair.eks.key_name
      autoscaling_enabled  = var.autoscaling_enabled
      ami_id               = data.aws_ami.eks_worker.id
    },
    {
      name                 = "k8s-worker-blue"
      asg_max_size         = var.blue_asg_max_size
      asg_desired_capacity = var.blue_asg_desired_capacity
      asg_min_size         = var.blue_asg_min_size
      instance_type        = var.blue_instance_type
      key_name             = aws_key_pair.eks.key_name
      autoscaling_enabled  = var.autoscaling_enabled
      ami_id               = data.aws_ami.eks_worker.id
    },
  ]
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.core-lib.account_id}:role/global-cloudops-role"
      username = "admin"
      groups   = ["system:masters"]
    },
 ]
}

module "eks" {
  source = "../eks"

  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  subnets                         = ["eks_subnet_id"]
  vpc_id                          = "eks_vpc_id"
  environment                     = var.environment
  map_roles                       = local.map_roles
  vpc_cidr                        = ["10.0.0.0/16"]
  vpc_region                      = var.vpc_region
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode
  worker_group_count              = 2
  worker_groups                   = local.worker_groups
  generate_config_map_aws_auth    = var.init_k8s
  generate_helm_rbac              = var.init_k8s
  generate_k8s_init               = var.init_k8s
  generate_kube2iam               = var.init_k8s
  generate_namespace              = var.init_k8s


  tags = {
    terraform_managed = "true"
    environment       = var.environment
    CostCenter        = "207"
    Stack             = var.environment
  }

}
