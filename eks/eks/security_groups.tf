resource "aws_security_group" "cluster" {
  name_prefix = var.cluster_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-eks_cluster_sg"
    },
  )
  count = var.cluster_security_group_id == "" ? 1 : 0
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
  count             = var.cluster_security_group_id == "" ? 1 : 0
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster[0].id
  source_security_group_id = local.worker_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
  count                    = var.cluster_security_group_id == "" ? 1 : 0
}

resource "aws_security_group" "workers" {
  name_prefix = aws_eks_cluster.this.name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  count       = var.worker_security_group_id == "" ? 1 : 0
  tags = merge(
    var.tags,
    {
      "Name"                                               = "${aws_eks_cluster.this.name}-eks_worker_sg"
      "kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
  count             = var.worker_security_group_id == "" ? 1 : 0
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers[0].id
  source_security_group_id = aws_security_group.workers[0].id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
  count                    = var.worker_security_group_id == "" ? 1 : 0
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[0].id
  source_security_group_id = local.cluster_security_group_id
  from_port                = var.worker_sg_ingress_from_port
  to_port                  = 65535
  type                     = "ingress"
  count                    = var.worker_security_group_id == "" ? 1 : 0
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[0].id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
  count                    = var.worker_security_group_id == "" ? 1 : 0
}

resource "aws_security_group_rule" "workers_ingress_private" {
  description       = "Allow workers ingress from private IPs"
  protocol          = "-1"
  security_group_id = aws_security_group.workers[0].id
  cidr_blocks       = ["10.0.0.0/8"]
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
  count             = var.cluster_security_group_id == "" ? 1 : 0
}

resource "aws_security_group" "efs" {
  name        = "${var.environment}-${var.cluster_name}-efs-k8s"
  description = "K8s Node EFS access"
  vpc_id      = var.vpc_id

  tags = {
    Name        = var.cluster_name
    environment = var.environment
  }
}

resource "aws_security_group_rule" "efs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs.id
}

resource "aws_security_group_rule" "allow-ingress_tcp_2049_from_vpc" {
  security_group_id = aws_security_group.efs.id
  description       = "K8s node EFS access"

  type        = "ingress"
  from_port   = 2049
  to_port     = 2049
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
}

