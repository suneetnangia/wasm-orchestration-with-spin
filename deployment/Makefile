dockerDir := ../wasm-shims/deployments/k3d
tmpSpinDir := ../wasm-shims/deployments/k3d/.tmp

all: build_k3d create_k3d_cluster install_redis deploy_app

build_k3d:
	@echo "Copying spin shim..."
	mkdir -p $(tmpSpinDir)
	cp -p ../apps/runtime/containerd-shim-spin-v1 $(tmpSpinDir)/containerd-shim-spin-v1

	@echo "Building k3d image..."
	docker build -t k3d-shim -f $(dockerDir)/Dockerfile $(dockerDir)

create_k3d_cluster:
	@echo "Creating k3d cluster..."
	k3d cluster create wasm-cluster --image k3d-shim --api-port 6551 -p '8001:30010@loadbalancer' --servers 1
	@echo "	@echo "Loading spin runtime..."
	kubectl apply -f ../apps/runtime/runtime.yaml

install_redis:
	@echo "Installing redis..."
	helm repo add redis-stack https://redis-stack.github.io/helm-redis-stack/
	helm repo update
	helm upgrade --install redis-stack redis-stack/redis-stack --set-string redis_stack.tag="latest" --reuse-values --namespace redis --create-namespace --wait
	kubectl apply -f ../apps/redis/redis.yaml

deploy_app: deploy_app_entry deploy_app_eventprocessor

deploy_app_entry:
	@echo "Deploying entry app..."
	sh ./deploy-workloads.sh entry

deploy_app_eventprocessor:
	@echo "Deploying eventprocessor app..."
	sh ./deploy-workloads.sh eventprocessor