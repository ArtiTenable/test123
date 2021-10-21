#---------------------------------------------------#  
# Internet Gateway
#---------------------------------------------------#  
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.igw_tags,
    var.tags,
  )
}

