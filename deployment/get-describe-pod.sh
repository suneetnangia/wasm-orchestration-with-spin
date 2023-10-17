#! /bin/bash
POD=`kubectl get pods | awk '/orderpr/ {print $1;exit}'`
echo "====================DESCRIBE $POD===================="
kubectl describe pods/$POD
echo "======================LOGS $POD======================"
POD=`kubectl get pods | awk '/fulfil/ {print $1;exit}'`
echo "====================DESCRIBE $POD===================="
kubectl describe pods/$POD
echo "======================LOGS $POD======================"
POD=`kubectl get pods | awk '/orderst/ {print $1;exit}'`
echo "====================DESCRIBE $POD===================="
kubectl describe pods/$POD
echo "======================LOGS $POD======================"
kubectl logs $POD
echo "======================DISK SIZE======================"
df -H