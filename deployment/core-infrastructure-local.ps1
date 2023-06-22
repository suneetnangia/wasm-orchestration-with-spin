curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
kubectl create namespace redis
kubectl apply -f ./redis-pod.yaml -n redis

