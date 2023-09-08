K3DCLUSTERNAME := wasm-cluster
K3DSHIMIMAGENAME := ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.9.0
DOCKERDIR := ./wasm-shims/deployments/k3d
APPSDIR := ./apps

all: create_k3d_cluster install_redis deploy_app run_integrationtest

create_k3d_cluster:
	@echo "Creating k3d cluster..."
	k3d cluster create $(K3DCLUSTERNAME) --image $(K3DSHIMIMAGENAME) --api-port 6551 -p '8001:30010@loadbalancer' -p '8002:80@loadbalancer' --servers 1
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

fmt:
	@echo "Checking formatting of code..."
	cargo fmt --all -- --check
	cargo clippy --all-targets --all-features --workspace -- --deny=warnings

build_push_app_images:
	@echo "Build and save apps images to artifacts folder..."
	sh ./deployment/build-push-workload-image.sh orderprocessor $(APPSDIR) $(GITHUBORG) $(GITHUBREPO)
	sh ./deployment/build-push-workload-image.sh fulfilmentprocessor $(APPSDIR) $(GITHUBORG) $(GITHUBREPO)

clean:
	@echo "Cleaning up..."
	k3d cluster delete $(K3DCLUSTERNAME)
	cargo clean
	rm -rf ./apps/orderprocessor/target
	rm -rf ./apps/orderprocessor/.spin
	rm -rf ./apps/fulfilmentprocessor/target
	rm -rf ./apps/fulfilmentprocessor/.spin
	rm -rf ./tests/target
	