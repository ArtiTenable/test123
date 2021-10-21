#!/bin/bash -xe

# Allow user supplied pre userdata code
${pre_userdata}

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_auth_base64}' --apiserver-endpoint '${endpoint}' --kubelet-extra-args '${kubelet_extra_args}' '${cluster_name}'

# Allow user supplied userdata code
${additional_userdata}

mkdir -p /data
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns}:/ /data
mkdir -p /data/data
chmod -R 0777 /data/data
umount /data

curl https://inspector-agent.amazonaws.com/linux/latest/install | bash

# Install SSM Agent
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
