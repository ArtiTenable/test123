resource "aws_security_group" "vpc_endpoint" {
  name   = "${var.name}-endpoint"
  vpc_id = aws_vpc.this[0].id

  tags = {
    terraform_managed = "true"
    Name              = "${var.name}-vpc-endpoint"
  }
}

resource "aws_security_group_rule" "vpc_endpoint_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["<cidr>"]

  security_group_id = aws_security_group.vpc_endpoint.id
}

resource "aws_security_group_rule" "vpc_endpoint_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.vpc_endpoint.id
}
