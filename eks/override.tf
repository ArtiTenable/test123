variable "alb_ingress_cidrs" {
  default = [
    "0.0.0.0/0"
  ]
}

variable "cluster_version" {
  default = "1.13"
}
variable "eks_ami_version" {
  default = "1.13-v20190927"
}


variable "autoscaling_enabled" {
  default = true
}

#---------------------------------------------------#
# Blue Worker Group:Settings
#---------------------------------------------------#

variable "blue_asg_max_size" {
  default = "0"
}

variable "blue_asg_desired_capacity" {
  default = "0"
}

variable "blue_asg_min_size" {
  default = "0"
}

variable "blue_instance_type" {
  default = "t2.small"
}

#---------------------------------------------------#
# Green Worker Group:Settings
#---------------------------------------------------#

variable "green_asg_max_size" {
  default = "2"
}

variable "green_asg_desired_capacity" {
  default = "2"
}

variable "green_asg_min_size" {
  default = "2"
}

variable "green_instance_type" {
  default = "t2.small"
}
