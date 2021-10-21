variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
}

variable "worker_create_initial_lifecycle_hooks" {
  description = "Whether to create initial lifecycle hooks provided in worker groups."
  type        = bool
  default     = false
}
variable "generate_config_map_aws_auth" {
  type = bool
}
variable "generate_kube2iam" {
  type = bool
}
variable "generate_namespace" {
  type = bool
}
variable "generate_helm_rbac" {
  type = bool
}
variable "generate_k8s_init" {
  type = bool
}

variable "vpc_cidr" {
  default     = ""
  description = "CIDR blocks for intra VPC communication"
}

variable "vpc_region" {
  default = ""
}

variable "environment" {
  default = ""
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32."
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.11"
}

variable "config_output_path" {
  description = "Determines where config files are placed if using configure_kubectl_session and you want config files to land outside the current working directory. Should end in a forward slash / ."
  default     = "/tmp"
}

variable "write_kubeconfig" {
  description = "Whether to write a kubeconfig file containing the cluster configuration."
  default     = true
}

variable "create_elb_service_linked_role" {
  description = "Whether to create the service linked role for the elasticloadbalancing service. Without this EKS cannot create ELBs."
  default     = false
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  default     = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources."
  default     = {}
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations. See workers_group_defaults for valid keys."
  default     = []
}

variable "worker_group_count" {
  description = "The number of maps contained within the worker_groups list."
  type        = string
  default     = "1"
}

variable "workers_group_defaults" {
  description = "Override default values for target groups. See workers_group_defaults_defaults in locals.tf for valid keys."
  type        = map(string)
  default     = {}
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster."
  default     = ""
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  default     = []
}

variable "worker_sg_ingress_from_port" {
  description = "Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443)."
  default     = "1025"
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to to fetch AWS EKS credentials."
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = map(string)
  default     = {}
}

variable "kubeconfig_name" {
  description = "Override the default name used for items kubeconfig."
  default     = ""
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  default     = "15m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  default     = "15m"
}

variable "provisioned_throughput_in_mibps" {
  default = "128"
}

variable "throughput_mode" {
  default = "bursting"
}
