#---------------------------------------------------#  
# Public subnet
#---------------------------------------------------#  
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 && false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs) ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format("%s-public-%s", var.name, element(var.azs, count.index))
    },
    var.public_subnet_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

#---------------------------------------------------#
# Private subnet
#---------------------------------------------------#
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format("%s-private-%s", var.name, element(var.azs, count.index))
    },
    var.private_subnet_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

#---------------------------------------------------#  
# Database subnet
#---------------------------------------------------#  
resource "aws_subnet" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format("%s-db-%s", var.name, element(var.azs, count.index))
    },
    var.database_subnet_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_db_subnet_group" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0

  name        = lower(var.name)
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database.*.id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.database_subnet_group_tags,
    var.tags,
  )
}

#---------------------------------------------------#  
# Redshift subnet
#---------------------------------------------------#  
resource "aws_subnet" "redshift" {
  count = var.create_vpc && length(var.redshift_subnets) > 0 ? length(var.redshift_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.redshift_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format("%s-redshift-%s", var.name, element(var.azs, count.index))
    },
    var.redshift_subnet_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_redshift_subnet_group" "redshift" {
  count = var.create_vpc && length(var.redshift_subnets) > 0 ? 1 : 0

  name        = var.name
  description = "Redshift subnet group for ${var.name}"
  subnet_ids  = aws_subnet.redshift.*.id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.redshift_subnet_group_tags,
    var.tags,
  )
}

#---------------------------------------------------#  
# ElastiCache subnet
#---------------------------------------------------#  
resource "aws_subnet" "elasticache" {
  count = var.create_vpc && length(var.elasticache_subnets) > 0 ? length(var.elasticache_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.elasticache_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format("%s-elasticache-%s", var.name, element(var.azs, count.index))
    },
    var.elasticache_subnet_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_elasticache_subnet_group" "elasticache" {
  count = var.create_vpc && length(var.elasticache_subnets) > 0 ? 1 : 0

  name        = var.name
  description = "ElastiCache subnet group for ${var.name}"
  subnet_ids  = aws_subnet.elasticache.*.id
}

#---------------------------------------------------#  
# intra subnets - private subnet without NAT gateway
#---------------------------------------------------#  
resource "aws_subnet" "intra" {
  count = var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.intra_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format("%s - %s", var.subnet_name, element(var.azs, count.index))
    },
    var.intra_subnet_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

