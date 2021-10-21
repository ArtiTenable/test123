resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.tags))

  triggers = {
    key                 = element(keys(var.tags), count.index)
    value               = element(values(var.tags), count.index)
    propagate_at_launch = "true"
  }
}

resource "aws_autoscaling_group" "workers" {
  count       = local.worker_group_count
  name_prefix = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  desired_capacity = lookup(
    var.worker_groups[count.index],
    "asg_desired_capacity",
    local.workers_group_defaults["asg_desired_capacity"],
  )
  max_size = lookup(
    var.worker_groups[count.index],
    "asg_max_size",
    local.workers_group_defaults["asg_max_size"],
  )
  min_size = lookup(
    var.worker_groups[count.index],
    "asg_min_size",
    local.workers_group_defaults["asg_min_size"],
  )
  force_delete = lookup(
    var.worker_groups[count.index],
    "asg_force_delete",
    local.workers_group_defaults["asg_force_delete"],
  )
  target_group_arns = lookup(
    var.worker_groups[count.index],
    "target_group_arns",
    local.workers_group_defaults["target_group_arns"]
  )
  service_linked_role_arn = lookup(
    var.worker_groups[count.index],
    "service_linked_role_arn",
    local.workers_group_defaults["service_linked_role_arn"],
  )
  launch_configuration = aws_launch_configuration.workers.*.id[count.index]
  vpc_zone_identifier = lookup(
    var.worker_groups[count.index],
    "subnets",
    local.workers_group_defaults["subnets"]
  )
  protect_from_scale_in = lookup(
    var.worker_groups[count.index],
    "protect_from_scale_in",
    local.workers_group_defaults["protect_from_scale_in"],
  )
  suspended_processes = lookup(
    var.worker_groups[count.index],
    "suspended_processes",
    local.workers_group_defaults["suspended_processes"]
  )
  enabled_metrics = lookup(
    var.worker_groups[count.index],
    "enabled_metrics",
    local.workers_group_defaults["enabled_metrics"]
  )
  placement_group = lookup(
    var.worker_groups[count.index],
    "placement_group",
    local.workers_group_defaults["placement_group"],
  )
  termination_policies = lookup(
    var.worker_groups[count.index],
    "termination_policies",
    local.workers_group_defaults["termination_policies"]
  )

  dynamic "initial_lifecycle_hook" {
    for_each = var.worker_create_initial_lifecycle_hooks ? lookup(var.worker_groups[count.index], "asg_initial_lifecycle_hooks", local.workers_group_defaults["asg_initial_lifecycle_hooks"]) : []
    content {
      name                    = initial_lifecycle_hook.value["name"]
      lifecycle_transition    = initial_lifecycle_hook.value["lifecycle_transition"]
      notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
      heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
      notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
      role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
      default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
    }
  }

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups[count.index], "name", count.index)}-eks_asg"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "kubernetes.io/cluster/${aws_eks_cluster.this.name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "k8s.io/cluster/${aws_eks_cluster.this.name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
      {
        "key" = "k8s.io/cluster-autoscaler/${lookup(
          var.worker_groups[count.index],
          "autoscaling_enabled",
          local.workers_group_defaults["autoscaling_enabled"],
        ) ? "enabled" : "disabled"}"
        "value"               = "true"
        "propagate_at_launch" = false
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.this.name}"
        "value"               = aws_eks_cluster.this.name
        "propagate_at_launch" = false
      },
      {
        "key" = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
        "value" = "${lookup(
          var.worker_groups[count.index],
          "root_volume_size",
          local.workers_group_defaults["root_volume_size"],
        )}Gi"
        "propagate_at_launch" = false
      },
    ],
    local.asg_tags,
    lookup(
      var.worker_groups[count.index],
      "tags",
      local.workers_group_defaults["tags"]
    )
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity, tags]
  }
}

resource "aws_launch_configuration" "workers" {
  name_prefix = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  associate_public_ip_address = lookup(
    var.worker_groups[count.index],
    "public_ip",
    local.workers_group_defaults["public_ip"],
  )

  security_groups = flatten([
    local.worker_security_group_id,
    var.worker_additional_security_group_ids,
    lookup(
      var.worker_groups[count.index],
      "additional_security_group_ids",
      local.workers_group_defaults["additional_security_group_ids"]
    )
  ])

  iam_instance_profile = element(aws_iam_instance_profile.workers.*.id, count.index)

  image_id = lookup(
    var.worker_groups[count.index],
    "ami_id",
    local.workers_group_defaults["ami_id"],
  )
  instance_type = lookup(
    var.worker_groups[count.index],
    "instance_type",
    local.workers_group_defaults["instance_type"],
  )
  key_name = lookup(
    var.worker_groups[count.index],
    "key_name",
    local.workers_group_defaults["key_name"],
  )
  user_data_base64 = base64encode(element(data.template_file.userdata.*.rendered, count.index))
  ebs_optimized = lookup(
    var.worker_groups[count.index],
    "ebs_optimized",
    lookup(
      local.ebs_optimized,
      lookup(
        var.worker_groups[count.index],
        "instance_type",
        local.workers_group_defaults["instance_type"],
      ),
      false,
    ),
  )
  enable_monitoring = lookup(
    var.worker_groups[count.index],
    "enable_monitoring",
    local.workers_group_defaults["enable_monitoring"],
  )
  spot_price = lookup(
    var.worker_groups[count.index],
    "spot_price",
    local.workers_group_defaults["spot_price"],
  )
  placement_tenancy = lookup(
    var.worker_groups[count.index],
    "placement_tenancy",
    local.workers_group_defaults["placement_tenancy"],
  )
  count = var.worker_group_count

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = lookup(
      var.worker_groups[count.index],
      "root_volume_size",
      local.workers_group_defaults["root_volume_size"],
    )
    volume_type = lookup(
      var.worker_groups[count.index],
      "root_volume_type",
      local.workers_group_defaults["root_volume_type"],
    )
    iops = lookup(
      var.worker_groups[count.index],
      "root_iops",
      local.workers_group_defaults["root_iops"],
    )
    delete_on_termination = true
  }
}

