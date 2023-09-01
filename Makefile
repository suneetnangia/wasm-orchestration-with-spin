K3DCLUSTERNAME := wasm-cluster
DOCKERDIR := ./wasm-shims/deployments/k3d
TMPSPINDIR := ./wasm-shims/deployments/k3d/.tmp
APPSDIR := ./apps

all: build_k3d_node_image create_k3d_cluster install_redis deploy_app run_integrationtest

build_k3d_node_image:
	@echo "Copying spin shim..."
	mkdir -p $(TMPSPINDIR)
	cp -p ./apps/runtime/containerd-shim-spin-v1 $(TMPSPINDIR)/containerd-shim-spin-v1

	@echo "Building k3d image..."
	docker build -t k3d-shim -f $(DOCKERDIR)/Dockerfile $(DOCKERDIR)

create_k3d_cluster:
	@echo "Creating k3d cluster..."
	k3d cluster create $(K3DCLUSTERNAME) --image k3d-shim --api-port 6551 -p '8001:30010@loadbalancer' -p '8002:80@loadbalancer' --servers 1
	@echo "Loading spin runtime..."
	kubectl apply -f ./apps/runtime/runtime.yaml

install_redis:
	@echo "Installing redis..."
	helm repo add redis-stack https://redis-stack.github.io/helm-redis-stack/
	helm repo update
	helm upgrade --install redis-stack redis-stack/redis-stack --set-string redis_stack.tag="latest" --reuse-values --namespace redis --create-namespace --wait
	kubectl delete svc redis-stack -n redis
	kubectl apply -f ./deployment/redis-stack/service.yaml -n redis

deploy_app: deploy_app_orderprocessor deploy_app_fulfilmentprocessor

deploy_app_orderprocessor:
	@echo "Deploying order processor app..."
	sh ./deployment/build-deploy-workload.sh orderprocessor $(K3DCLUSTERNAME) $(APPSDIR)

deploy_app_fulfilmentprocessor:
	@echo "Deploying fulfilment processor app..."
	sh ./deployment/build-deploy-workload.sh fulfilmentprocessor $(K3DCLUSTERNAME) $(APPSDIR)

run_integrationtest:
	@echo "Running integration test..."
	cargo test --manifest-path ./tests/Cargo.toml --package integrationtest --lib -- create_order_test --exact --nocapture

test: clean all

save_images: all
	@echo "Saving apps images as artifacts..."
	sh ./deployment/save-image.sh orderprocessor $(APPSDIR)
	sh ./deployment/save-image.sh fulfilmentprocessor $(APPSDIR)

clean:
	@echo "Cleaning up..."
	k3d cluster delete $(K3DCLUSTERNAME)
	rm -rf $(TMPSPINDIR)
	cargo clean
	rm -rf ./apps/orderprocessor/target
	rm -rf ./apps/orderprocessor/.spin
	rm -rf ./apps/fulfilmentprocessor/target
	rm -rf ./apps/fulfilmentprocessor/.spin
	rm -rf ./tests/target
	