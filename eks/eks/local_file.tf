locals {
  uniq = substr(uuid(),0,6)
}


module "config_map_aws_auth" {
  source = "../agnostic-utils/file_in_temp_dir"
  content = data.template_file.config_map_aws_auth.rendered
  filename = "yaml/config-map-aws-auth_${var.cluster_name}.yaml"
  path_prefix = "${local.config_output_path}"
  uniq = local.uniq
  generate = var.generate_config_map_aws_auth
}

module "kube2iam" {
  source = "../agnostic-utils/file_in_temp_dir"
  content = data.template_file.kube2iam.rendered
  filename = "yaml/kube2iam.yaml"
  path_prefix = "${local.config_output_path}"
  uniq = local.uniq
  generate = var.generate_kube2iam
}

module "namespace" {
  source = "../agnostic-utils/file_in_temp_dir"
  content = data.template_file.namespace.rendered
  filename = "yaml/namespace.yaml"
  path_prefix = "${local.config_output_path}"
  uniq = local.uniq
  generate = var.generate_namespace
}

module "helm_rbac" {
  source = "../agnostic-utils/file_in_temp_dir"
  content = data.template_file.helm_rbac.rendered
  filename = "yaml/helm-rbac.yaml"
  path_prefix = "${local.config_output_path}"
  uniq = local.uniq
  generate = var.generate_helm_rbac
}

module "k8s_init" {
  source = "../agnostic-utils/file_in_temp_dir"
  content = data.template_file.k8s_init.rendered
  filename = "k8s-init.sh"
  path_prefix = "${local.config_output_path}"
  uniq = local.uniq
  generate = var.generate_k8s_init
}

output "temp_dir" {
  value = module.k8s_init.temp_dir
}
