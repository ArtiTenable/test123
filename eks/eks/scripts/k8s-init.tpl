#!/usr/bin/env bash
#---------------------------------------------------#
#     <Christopher Stobie> cstobie@minervagroup.io
#---------------------------------------------------#  
# This is to force rendering ${random_string}
#---------------------------------------------------#
# This script assumes you have kubeconfig setup
#---------------------------------------------------#  

#### First create all needed service accounts
kubectl create clusterrolebinding serviceaccounts-view --clusterrole=view --group=system:serviceaccounts # needed for controlroom
kubectl create serviceaccount --namespace kube-system tiller # needed for helm

#### Then create permissions
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller # needed for helm

#### Then apply yaml files
## yaml files should not be order dependent at this point
for YAML in $(ls yaml) ; do
  kubectl apply -f $YAML
done

#### Install tiller
helm init --service-account tiller --upgrade
