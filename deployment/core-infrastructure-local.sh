shimSpinDir=../wasm-shims/containerd-shim-spin-v1
dockerDir=../wasm-shims/deployments/k3d
tmpSpinDir=../wasm-shims/deployments/k3d/.tmp/containerd-shim-spin-v1

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Build Spin shim
cargo build --release --manifest-path=$shimSpinDir/Cargo.toml
cp $shimSpinDir/target/release/containerd-shim-spin-v1 $tmpSpinDir

# Build k3d image
docker build -t k3d-shim -f $dockerDir/Dockerfile $dockerDir

# Create k3d cluster
k3d cluster create wasm-cluster --image k3d-shim -p '8081:80@loadbalancer' --servers 1

# Load Spin runtime
kubectl apply -f ../apps/runtime/runtime.yaml

# Deploy Redis (pull public Redis image, save it to local directory and import into k3d cluster)
helm install redis-stack ./helm/redis-stack --set-string redis_stack.tag="latest" --namespace redis --create-namespace --wait
buildWorkloads()
{
  cd ../apps/$1
  spin build
  cp -r ../../target .
  # spin k8s build
  mkdir -p tmp
  docker buildx build -f Dockerfile -t $1:latest . --load --platform=wasi/wasm32 --provenance=false
  docker save -o tmp/$1.tar $1:latest
  k3d image import tmp/$1.tar -c wasm-cluster
  rm -r tmp
  spin k8s deploy
  cd ../../deployment
}
# Build and load workloads
buildWorkloads entry
buildWorkloads eventprocessor

