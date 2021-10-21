title 'VPC and SG setup'


# load data from env_var file
env_data = yaml(content: inspec.profile.file('env_var.yaml')).params

AA_ENV = env_data[0]['data']['env_name']
VPC_CIDR= env_data[0]['data']['vpc_cidr']


# load data from terraform output
content = inspec.profile.file("networking.json")
params = JSON.parse(content)

VPC_ID = params['vpc_id']['value']
PRI_SUBNET_ID_0 = params['private_subnets']['value'][0]
PRI_SUBNET_ID_1 = params['private_subnets']['value'][1]
PRI_SUBNET_ID_2 = params['private_subnets']['value'][2]
PUB_SUBNET_ID_0 = params['public_subnets']['value'][0]
PUB_SUBNET_ID_1 = params['public_subnets']['value'][1]
PUB_SUBNET_ID_2 = params['public_subnets']['value'][2]
PRI_ROUTETABLE_ID_0 = params['private_route_table_ids']['value'][0]
PRI_ROUTETABLE_ID_1 = params['private_route_table_ids']['value'][1]
PRI_ROUTETABLE_ID_2 = params['private_route_table_ids']['value'][2]
PUB_ROUTETABLE_ID = params['public_route_table_ids']['value'][0]
SG_HTTP = AA_ENV + '-http'

# execute test
describe aws_vpc(vpc_id: VPC_ID) do
  it { should exist }
  its ('state') { should eq 'available' }
  its('cidr_block') { should cmp VPC_CIDR }
end

describe aws_subnets.where( vpc_id: VPC_ID) do
  its('states') { should_not include 'pending' }
end

describe aws_subnets.where(vpc_id: VPC_ID) do
  its('subnet_ids') { should include PRI_SUBNET_ID_0 }
  its('subnet_ids') { should include PRI_SUBNET_ID_1 }
  its('subnet_ids') { should include PRI_SUBNET_ID_2 }
end


describe aws_subnets.where(vpc_id: VPC_ID) do
  its('subnet_ids') { should include PUB_SUBNET_ID_0 }
  its('subnet_ids') { should include PUB_SUBNET_ID_1 }
  its('subnet_ids') { should include PUB_SUBNET_ID_2 }
end

describe aws_route_tables do
  it { should exist }
end

describe aws_route_tables do
  its('route_table_ids') { should include PRI_ROUTETABLE_ID_0 }
  its('route_table_ids') { should include PRI_ROUTETABLE_ID_1 }
  its('route_table_ids') { should include PRI_ROUTETABLE_ID_2 }
  its('route_table_ids') { should include PUB_ROUTETABLE_ID }
end

describe aws_route_tables do
  its('vpc_ids') { should include VPC_ID }
end

describe aws_security_groups do
  it { should exist }
end

describe aws_security_groups do
  its('entries.count') { should be > 1 }
end

describe aws_security_groups.where( group_name: SG_HTTP ) do
  it { should exist }
end
