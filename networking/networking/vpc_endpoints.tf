#---------------------------------------------------#  
# VPC Endpoint for S3
#---------------------------------------------------#  
data "aws_vpc_endpoint_service" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  service = "s3"
  filter {
    name   = "vpc_id"
    values = [aws_vpc.this[0].id]
  }
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this[0].id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "intra_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.intra_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.intra.*.id, 0)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}

#---------------------------------------------------#  
# VPC Endpoint for DynamoDB
#---------------------------------------------------#  
data "aws_vpc_endpoint_service" "dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this[0].id
  service_name = data.aws_vpc_endpoint_service.dynamodb[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "intra_dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint && length(var.intra_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.intra.*.id, 0)
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = aws_route_table.public[0].id
}

#---------------------------------------------------#  
# VPC Endpoint for ECR and ECR API
#---------------------------------------------------# 
data "aws_vpc_endpoint_service" "ecr_api" {
  service = "ecr.api"
}
/*
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this[0].id
  service_name        = data.aws_vpc_endpoint_service.ecr_api.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  subnet_ids          = aws_subnet.private.*.id
  private_dns_enabled = true
  tags = merge(
    {
      "Name" = format("%s", var.default_vpc_name)
    },
    var.default_vpc_tags,
    var.tags,
  )
}

data "aws_vpc_endpoint_service" "ecr_dkr" {
  service = "ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this[0].id
  service_name        = data.aws_vpc_endpoint_service.ecr_dkr.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  subnet_ids          = aws_subnet.private.*.id
  private_dns_enabled = true
  tags = merge(
    {
      "Name" = format("%s", var.default_vpc_name)
    },
    var.default_vpc_tags,
    var.tags,
  )
}
*/

