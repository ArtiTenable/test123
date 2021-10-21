variable "ssh_key_name" {
  default = "cloudops"
}

variable "dns_zone_name" {
  default = "dev.rpaworker.com"
}

variable "tf_remote_state_s3_bucket_global_region" {
  default = "us-east-1"
}

variable "tf_remote_state_s3_bucket_global_profile_name" {
  default = "dev"
}

variable "vpc_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "dev"
}

variable "vpc_name" {
  default = "dev-vpc"
}

variable "aws_provider_profile_name" {
  default = "aa-iam-manager"
}

variable "tf_remote_state_s3_bucket_prefix" {
  default = "aa-terraform"
}

variable "tf_remote_state_s3_bucket_current_environment_region" {
  default = "us-east-1"
}
