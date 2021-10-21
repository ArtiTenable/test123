resource "aws_security_group" "this" {
  name        = "${var.environment}-eks-alb"
  description = "Allow all inbound traffic"
  vpc_id      = "eks_vpc_id"

  tags = {
    Name        = "${var.environment}-eks-alb"
    environment = var.environment
  }
}

resource "aws_security_group_rule" "this_http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = var.alb_ingress_cidrs

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_https_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.alb_ingress_cidrs

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.id
}

