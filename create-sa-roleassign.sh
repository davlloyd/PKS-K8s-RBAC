#!/bin/bash
# Create ServiceAccount, add to specified role, get token

if [[ -z "$1" ]] ;then
  echo "usage: $0 <username> <namespace> <role>"
  exit 1
fi

user=$1

if [[ -z "$2" ]] ;then
  namespace="default"
else
  namespace=$2
fi

if [[ -z "$3" ]] ;then
  role="cluster-admin"
  #role="node-reader"
else
  role=$3
fi

bindingname="${user}-role"

kubectl create sa ${user}
secret=$(kubectl get sa ${user} -o json | jq -r '.secrets[].name')
echo "secret = ${secret}"

echo "Delete rolebinding if already exists"
kubectl delete clusterrolebinding ${bindingname}

echo "Adding ${user} to role ${role}"
kubectl create clusterrolebinding ${bindingname} \
    --clusterrole ${role} \
    --serviceaccount "${namespace}:${user}"


kubectl get secret ${secret} -o json | jq -r '.data["ca.crt"]' | base64 -D > ca.crt
user_token=$(kubectl get secret ${secret} -o json | jq -r '.data["token"]' | base64 -D)
echo "token = ${user_token}"

echo "done!"
