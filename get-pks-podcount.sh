#!/bin/bash
# Get an overall POD count for PKS

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ;then
  echo "usage: $0 <pks_api_url> <account> <password>"
  exit 1
fi

pksapi=$1
account=$2
password=$3
echo "Connecting to ${pksapi} with account ${account}"

retval=$(pks login -a ${pksapi} -u ${account} -p ${password} -k)

for i in $(pks clusters --json | jq -r '.[].name')
do
  pks get-credentials $i
  pods=$(kubectl get pods --all-namespaces -o json | jq -r '.items | length')  
  count+=pods
done
e