title 'EKS setup'

# load data from env_var file
env_data = yaml(content: inspec.profile.file('env_var.yaml')).params

AA_ENV = env_data[0]['data']['env_name']
REGION = env_data[0]['data']['env_reg'] 
EKS_VER = env_data[0]['data']['eks_ver']
EKS_CLUSTER = AA_ENV + '-' + REGION + '-' + 'eks'



# execute test
describe aws_eks_cluster(EKS_CLUSTER) do
  it { should exist }
  its('status') { should eq 'ACTIVE' }
  its('version') { should cmp EKS_VER }
  # its('security_group_ids') { should include 'sg-07e09ed88d8ca162c' }
  its('subnets_count') { should eq 3 }
  its('security_groups_count') { should eq 1 }
  # its('role_arn') { should cmp 'arn:aws:iam::012345678910:role/eks-service-role' }
end
