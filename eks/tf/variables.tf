variable "alb_ingress_cidrs" {
  default = []
}


variable "eks_ami_version" {
  default = "1.13-v20190927"
}
variable "autoscaling_enabled" {
  default = "true"
}

variable "cluster_version" {
  default = "1.13"
}

variable "init_k8s" {
  default = false
}

#---------------------------------------------------#
# Blue Worker Group:Settings
#---------------------------------------------------#
variable "blue_asg_max_size" {
  default = "10"
}

variable "blue_asg_desired_capacity" {
  default = "10"
}

variable "blue_asg_min_size" {
  default = "10"
}

variable "blue_instance_type" {
  default = "c5.2xlarge"
}

#---------------------------------------------------#
# Blue Worker Group:Settings
#---------------------------------------------------#
variable "green_asg_max_size" {
  default = "10"
}

variable "green_asg_desired_capacity" {
  default = "10"
}

variable "green_asg_min_size" {
  default = "10"
}

variable "green_instance_type" {
  default = "c5.2xlarge"
}



variable "provisioned_throughput_in_mibps" {
  default = "0"
}

variable "throughput_mode" {
  default = "bursting"
}
