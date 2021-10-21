data "template_file" "autoscaler" {
  template = file("${path.module}/templates/autoscaler-values.tpl")

  vars = {
    cluster_name = var.cluster_name
    vpc_region   = var.vpc_region
  }
}

data "template_file" "worker_role_arns" {
  count    = var.worker_group_count
  template = file("${path.module}/templates/worker-role.tpl")

  vars = {
    worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${element(aws_iam_instance_profile.workers.*.role, count.index)}"
  }
}

data "template_file" "config_map_aws_auth" {
  template = file("${path.module}/templates/config-map-aws-auth.yaml.tpl")

  vars = {
    worker_role_arn = join(
      "",
      distinct(
        concat(
          data.template_file.worker_role_arns.*.rendered,
        ),
      ),
    )
    map_users    = yamlencode(var.map_users),
    map_roles    = yamlencode(var.map_roles),
    map_accounts = yamlencode(var.map_accounts)
  }
}


data "template_file" "kube2iam" {
  template = file("${path.module}/templates/kube2iam.tpl")

  vars = {
    iam_role_arn = aws_iam_role.workers.arn
  }
}

data "template_file" "kube2iam-trust" {
  template = file("${path.module}/policies/kube2iam-trust.tpl")

  vars = {
    iam_role_arn = aws_iam_role.workers.arn
  }
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    cluster_name              = aws_eks_cluster.this.name
    kubeconfig_name           = local.kubeconfig_name
    endpoint                  = aws_eks_cluster.this.endpoint
    region                    = data.aws_region.current.name
    cluster_auth_base64       = aws_eks_cluster.this.certificate_authority[0].data
    aws_authenticator_command = var.kubeconfig_aws_authenticator_command
    aws_authenticator_additional_args = length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join(
      "\n        - ",
      var.kubeconfig_aws_authenticator_additional_args,
    )}" : ""
    aws_authenticator_env_variables = length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join(
      "\n",
      data.template_file.aws_authenticator_env_variables.*.rendered,
    )}" : ""
  }
}

data "template_file" "aws_authenticator_env_variables" {
  template = <<EOF
        - name: $${key}
          value: $${value}
EOF


  count = length(var.kubeconfig_aws_authenticator_env_variables)

  vars = {
    value = element(
      values(var.kubeconfig_aws_authenticator_env_variables),
      count.index,
    )
    key = element(
      keys(var.kubeconfig_aws_authenticator_env_variables),
      count.index,
    )
  }
}

data "template_file" "userdata" {
  count = var.worker_group_count

  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name        = aws_eks_cluster.this.name
    efs_dns             = aws_efs_file_system.this.dns_name
    endpoint            = aws_eks_cluster.this.endpoint
    cluster_auth_base64 = aws_eks_cluster.this.certificate_authority[0].data
    pre_userdata = lookup(
      var.worker_groups[count.index],
      "pre_userdata",
      local.workers_group_defaults["pre_userdata"],
    )
    additional_userdata = lookup(
      var.worker_groups[count.index],
      "additional_userdata",
      local.workers_group_defaults["additional_userdata"],
    )
    kubelet_extra_args = lookup(
      var.worker_groups[count.index],
      "kubelet_extra_args",
      local.workers_group_defaults["kubelet_extra_args"],
    )
  }
}

data "template_file" "namespace" {
  template = file("${path.module}/templates/namespace.tpl")

  vars = {
    environment = var.environment
  }
}

data "template_file" "helm_rbac" {
  template = file("${path.module}/templates/helm-rbac.tpl")
}

data "template_file" "k8s_init" {
  template = file("${path.module}/scripts/k8s-init.tpl")

  vars = {
    config_output_path = local.config_output_path
    environment        = var.environment
    cluster_name       = var.cluster_name
    region             = var.vpc_region
    cluster_arn        = aws_eks_cluster.this.arn
    random_string      = uuid()
  }
}

