#---------------------------------------------------#
# Default SSH Access
#---------------------------------------------------#
resource "aws_security_group" "ssh" {
  name   = "${var.environment}-ssh"
  vpc_id = module.vpc.vpc_id

  tags = {
    terraform_managed = "true"
    Name              = "ssh"
    environment       = var.environment
  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/8"]

  security_group_id = aws_security_group.ssh.id
}

resource "aws_security_group_rule" "ssh_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ssh.id
}

#---------------------------------------------------#  
# Default LB Access
#---------------------------------------------------#  
resource "aws_security_group" "http" {
  name   = "${var.environment}-http"
  vpc_id = module.vpc.vpc_id

  tags = {
    terraform_managed = "true"
    Name              = "http"
    environment       = var.environment
  }
}

resource "aws_security_group_rule" "http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/8"]

  security_group_id = aws_security_group.http.id
}

resource "aws_security_group_rule" "http_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.http.id
}

