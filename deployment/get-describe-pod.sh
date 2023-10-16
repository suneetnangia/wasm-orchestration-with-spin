#! /bin/bash

# get the version from the spin.toml file
echo "====================DESCRIBE===================="
kubectl describe pods/$POD
echo "======================LOGS======================"
kubectl logs $POD