#---------------------------------------------------#  
# Publiс routes
#---------------------------------------------------#  
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-public", var.name)
    },
    var.public_route_table_tags,
    var.tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

#---------------------------------------------------#  
# Private routes
# There are so many routing tables as the largest amount of subnets of each type (really?)
#---------------------------------------------------#  
resource "aws_route_table" "private" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-private" : format("%s-private-%s", var.name, element(var.azs, count.index))
    },
    var.private_route_table_tags,
    var.tags,
  )

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}

resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

#---------------------------------------------------#  
# Intra routes
#---------------------------------------------------#  
resource "aws_route_table" "intra" {
  count = var.create_vpc && length(var.intra_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = "${var.name}-intra"
    },
    var.intra_route_table_tags,
    var.tags,
  )
}

