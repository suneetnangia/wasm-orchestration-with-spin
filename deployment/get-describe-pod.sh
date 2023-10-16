#! /bin/bash

# get the version from the spin.toml file
POD=`kubectl get pods | awk '/orderpro/ {print $1;exit}'`
echo "====================DESCRIBE===================="
kubectl describe pods/$POD
echo "======================LOGS======================"
kubectl logs $POD