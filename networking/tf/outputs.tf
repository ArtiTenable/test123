output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnets_arns" {
  value = module.vpc.private_subnets_arns
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "supernet_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "nat_eips_public_ips" {
  value = module.vpc.nat_public_ips
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}
