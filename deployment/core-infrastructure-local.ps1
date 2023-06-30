$tmpDir = "../wasm-shims/deployments/k3d/.tmp/containerd-shim-spin-v1"
$shimDir = "../wasm-shims/containerd-shim-spin-v1"
$dockerDir = "../wasm-shims/deployments/k3d"
$tmpDir = "../wasm-shims/deployments/k3d/.tmp/containerd-shim-spin-v1"

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Build Spin shim
Write-Host $shimDir
cargo build --release --manifest-path=$shimDir/Cargo.toml
Copy-Item $shimDir/target/release `
    -Destination ../wasm-shims/deployments/k3d/.tmp/containerd-shim-spin-v1 -Recurse -Force

# Build k3d image
docker build -t k3d-shim-test -f $dockerDir/Dockerfile $dockerDir

# Create k3d cluster
k3d cluster create wasm-spin-cluster --image k3d-shim-test --api-port 6551 -p '8082:80@loadbalancer' --agents 1
#kubectl create namespace redis
#kubectl apply -f ./redis-pod.yaml -n redis


