dockerDir=../wasm-shims/deployments/k3d
tmpSpinDir=../wasm-shims/deployments/k3d/.tmp

# Copy Spin shim
mkdir -p $tmpSpinDir
cp -p ../apps/runtime/containerd-shim-spin-v1 $tmpSpinDir/containerd-shim-spin-v1

# Build k3d image
docker build -t k3d-shim -f $dockerDir/Dockerfile $dockerDir

# Create k3d cluster
k3d cluster create wasm-cluster --image k3d-shim --api-port 6551 -p '8001:30010@loadbalancer' --servers 1

# Load Spin runtime
kubectl apply -f ../apps/runtime/runtime.yaml

# Deploy Redis (pull public Redis image, save it to local directory and import into k3d cluster)
helm repo add redis-stack https://redis-stack.github.io/helm-redis-stack/
helm repo update
helm upgrade --install redis-stack redis-stack/redis-stack --set-string redis_stack.tag="latest" --reuse-values --namespace redis --create-namespace --wait
# Replace Helm service
kubectl apply -f ./helm/redis-stack/service.yaml -n redis

# Build and load workloads
buildWorkloads()
{
  cd ../apps/$1
  spin build
  cp -r ../../target .
  # spin k8s build
  mkdir -p tmp
  docker buildx build -f Dockerfile -t $1:v1 . --load --platform=wasi/wasm32 --provenance=false
  docker save -o tmp/$1.tar $1:v1
  k3d image import tmp/$1.tar -c wasm-cluster
  rm -r tmp
  spin k8s deploy
  cd ../../deployment
}
# Build and load workloads
buildWorkloads entry
buildWorkloads eventprocessor

