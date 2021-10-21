resource "aws_iam_role" "cluster" {
  name_prefix        = var.cluster_name
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_service_linked_role" "elasticloadbalancing" {
  count            = var.create_elb_service_linked_role ? 1 : 0
  aws_service_name = "elasticloadbalancing.amazonaws.com"
}

resource "aws_iam_role" "workers" {
  name_prefix        = aws_eks_cluster.this.name
  assume_role_policy = data.aws_iam_policy_document.workers_assume_role_policy.json
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = aws_eks_cluster.this.name
  role = lookup(
    var.worker_groups[count.index],
    "iam_role_id",
    local.workers_group_defaults["iam_role_id"],
  )
  count = var.worker_group_count
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_policy" "autoscaler" {
  name_prefix = "eks-worker-autoscaler-${aws_eks_cluster.this.name}"
  description = "EKS worker autoscaler for cluster ${aws_eks_cluster.this.name}"
  policy      = file("${path.module}/policies/autoscaler.json")
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.workers.name
}

#---------------------------------------------------#
# kube2iam
#---------------------------------------------------#
resource "aws_iam_role" "kube2iam" {
  name_prefix        = "${format("%.14s", aws_eks_cluster.this.name)}-kube2iam"
  assume_role_policy = data.template_file.kube2iam-trust.rendered
}

resource "aws_iam_policy" "kube2iam" {
  name_prefix = "eks-worker-kube2iam-${aws_eks_cluster.this.name}"
  description = "EKS worker kube2iam for cluster ${aws_eks_cluster.this.name}"
  policy      = file("${path.module}/policies/kube2iam.json")
}

resource "aws_iam_role_policy_attachment" "kube2iam" {
  policy_arn = aws_iam_policy.kube2iam.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "kube2iam_policy_trust_attach" {
  policy_arn = aws_iam_policy.kube2iam.arn
  role       = aws_iam_role.kube2iam.name
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.this.name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this.name}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}

#---------------------------------------------------#
# Alb ingress controller iam role
#---------------------------------------------------#
resource "aws_iam_role" "alb_ingress" {
  name_prefix = var.cluster_name

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "",
			"Effect": "Allow",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		},
		{
			"Sid": "",
			"Effect": "Allow",
			"Principal": {
				"AWS": "${aws_iam_role.kube2iam.arn}"
			},
			"Action": "sts:AssumeRole"
		}
	]
}

EOF

}

resource "aws_iam_role_policy_attachment" "alb_ingress" {
  policy_arn = aws_iam_policy.alb_ingress.arn
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_policy" "alb_ingress" {
  name_prefix = "eks-alb-ingress-${aws_eks_cluster.this.name}"
  description = "EKS Policy for ALB Ingress Controller for ${aws_eks_cluster.this.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cognito-idp:DescribeUserPoolClient"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}

EOF

}

