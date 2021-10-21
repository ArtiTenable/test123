
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_create_timeout | Timeout value when creating the EKS cluster. | string | `15m` | no |
| cluster_delete_timeout | Timeout value when deleting the EKS cluster. | string | `15m` | no |
| cluster_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | string | - | yes |
| cluster_security_group_id | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32. | string | `` | no |
| cluster_version | Kubernetes version to use for the EKS cluster. | string | `1.10` | no |
| config_output_path | Determines where config files are placed if using configure_kubectl_session and you want config files to land outside the current working directory. Should end in a forward slash / . | string | `./` | no |
| create_elb_service_linked_role | Whether to create the service linked role for the elasticloadbalancing service. Without this EKS cannot create ELBs. | string | `false` | no |
| kubeconfig_aws_authenticator_additional_args | Any additional arguments to pass to the authenticator such as the role to assume. e.g. ["-r", "MyEksRole"]. | list | `<list>` | no |
| kubeconfig_aws_authenticator_command | Command to use to to fetch AWS EKS credentials. | string | `aws-iam-authenticator` | no |
| kubeconfig_aws_authenticator_env_variables | Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = "eks"}. | map | `<map>` | no |
| kubeconfig_name | Override the default name used for items kubeconfig. | string | `` | no |
| manage_aws_auth | Whether to write and apply the aws-auth configmap file. | string | `true` | no |
| map_accounts | Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map_roles | Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| map_users | Additional IAM users to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format. | list | `<list>` | no |
| subnets | A list of subnets to place the EKS cluster and workers within. | list | - | yes |
| tags | A map of tags to add to all resources. | map | `<map>` | no |
| vpc_id | VPC where the cluster and workers will be deployed. | string | - | yes |
| worker_additional_security_group_ids | A list of additional security group ids to attach to worker instances | list | `<list>` | no |
| worker_group_count | The number of maps contained within the worker_groups list. | string | `1` | no |
| worker_groups | A list of maps defining worker group configurations. See workers_group_defaults for valid keys. | list | `<list>` | no |
| worker_security_group_id | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster. | string | `` | no |
| worker_sg_ingress_from_port | Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443). | string | `1025` | no |
| workers_group_defaults | Override default values for target groups. See workers_group_defaults_defaults in locals.tf for valid keys. | map | `<map>` | no |
| write_kubeconfig | Whether to write a kubeconfig file containing the cluster configuration. | string | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_certificate_authority_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster_id | The name/id of the EKS cluster. |
| cluster_security_group_id | Security group ID attached to the EKS cluster. |
| cluster_version | The Kubernetes server version for the EKS cluster. |
| config_map_aws_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| worker_iam_role_arn | default IAM role ARN for EKS worker groups |
| worker_iam_role_name | default IAM role name for EKS worker groups |
| worker_security_group_id | Security group ID attached to the EKS workers. |
| workers_asg_arns | IDs of the autoscaling groups containing workers. |
| workers_asg_names | Names of the autoscaling groups containing workers. |

