resource "aws_efs_file_system" "this" {
  creation_token                  = "k8s-efs-${var.environment}"
  encrypted                       = true
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps

  tags = {
    CostCenter        = "207"
    Stack             = var.environment
    Name              = "k8s-efs-${var.environment}"
    environment       = var.environment
    terraform_managed = "true"
  }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnets)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = element(var.subnets, count.index)
  security_groups = [aws_security_group.efs.id]
}

