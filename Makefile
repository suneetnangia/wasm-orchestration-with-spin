#! /bin/bash
K3DCLUSTERNAME := wasm-cluster
K3DSHIMIMAGENAME := ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.9.1
DOCKERDIR := ./wasm-shims/deployments/k3d
APPSDIR := ./apps/mqtt
PORTFORWARDING := -p '8001:30010@loadbalancer' -p '8002:80@loadbalancer' -p '1883:31883@loadbalancer'
redis_communication: APPSDIR := ./apps/redis
redis_communication: PORTFORWARDING := -p '8001:30010@loadbalancer' -p '8002:80@loadbalancer'
APPSDIRRUNTIME := ./apps/runtime

all: mqtt_communication

mqtt_communication: create_k3d_cluster upgrade_spin_shim install_redis install_mosquitto deploy_app run_integrationtest

redis_communication: create_k3d_cluster install_redis deploy_app run_integrationtest

create_k3d_cluster:
	@echo "Creating k3d cluster..."
	k3d cluster create $(K3DCLUSTERNAME) --image $(K3DSHIMIMAGENAME) --api-port 6551 $(PORTFORWARDING) --servers 1
	@echo "Loading spin runtime..."
	kubectl apply -f $(APPSDIRRUNTIME)/runtime.yaml

upgrade_spin_shim:
	@echo "Upgrading spin shim..."
	k3d cluster stop $(K3DCLUSTERNAME)
	docker cp -a $(APPSDIRRUNTIME)/containerd-shim-spin-v1 k3d-$(K3DCLUSTERNAME)-server-0:/bin/containerd-shim-spin-v1
	k3d cluster start $(K3DCLUSTERNAME)
	docker exec k3d-$(K3DCLUSTERNAME)-server-0 chmod -R 500 ./bin/containerd-shim-spin-v1

install_redis:
	@echo "Installing redis..."
	helm repo add redis-stack https://redis-stack.github.io/helm-redis-stack/
	helm repo update
	helm upgrade --install redis-stack redis-stack/redis-stack --set-string redis_stack.tag="latest" --reuse-values --namespace redis --create-namespace --wait
	kubectl delete svc redis-stack -n redis
	kubectl apply -f ./deployment/redis-stack/service.yaml -n redis
	
install_mosquitto:
	@echo "Installing mosquito..."
	helm upgrade --install mosquitto ./deployment/mosquitto --namespace mosquitto --create-namespace --wait

deploy_app: deploy_app_orderprocessor deploy_app_fulfilmentprocessor deploy_app_orderstatusprovider
	rm -r target

deploy_app_orderprocessor:
	@echo "Deploying order processor app..."
	sh ./deployment/build-deploy-workload.sh orderprocessor $(K3DCLUSTERNAME) $(APPSDIR)

deploy_app_fulfilmentprocessor:
	@echo "Deploying fulfilment processor app..."
	sh ./deployment/build-deploy-workload.sh fulfilmentprocessor $(K3DCLUSTERNAME) $(APPSDIR)

deploy_app_orderstatusprovider:
	@echo "Deploying orderstatusprovider processor app..."
	sh ./deployment/build-deploy-workload.sh orderstatusprovider $(K3DCLUSTERNAME) ./apps/shared

run_integrationtest:
	@echo "Running integration test..."
	@echo "###########################"
	sh ./deployment/get-describe-pod.sh orderprocessor
	@echo "###########################"
	@echo "Running integration test..."
	RUST_BACKTRACE=full cargo test --manifest-path ./tests/Cargo.toml --package integrationtest --lib -- create_order_test --exact --nocapture

test: clean all

test_redis: clean redis_communication

fmt:
	@echo "Checking formatting of code..."
	cargo fmt --all -- --check
	cargo clippy --all-targets --all-features --workspace -- --deny=warnings

build_push_app_images:
	@echo "Build and save apps images to artifacts folder..."
	sh ./deployment/build-push-workload-image.sh orderprocessor-mqtt ./apps/mqtt $(GITHUBORG) $(GITHUBREPO)
	sh ./deployment/build-push-workload-image.sh fulfilmentprocessor-mqtt ./apps/mqtt $(GITHUBORG) $(GITHUBREPO)
	sh ./deployment/build-push-workload-image.sh orderprocessor-redis ./apps/redis $(GITHUBORG) $(GITHUBREPO)
	sh ./deployment/build-push-workload-image.sh fulfilmentprocessor-redis ./apps/redis $(GITHUBORG) $(GITHUBREPO)
	sh ./deployment/build-push-workload-image.sh orderstatusprovider ./apps/shared $(GITHUBORG) $(GITHUBREPO)

clean:
	@echo "Cleaning up..."
	k3d cluster delete $(K3DCLUSTERNAME)
	cargo clean
	rm -rf ./apps/mqtt/orderprocessor/target
	rm -rf ./apps/mqtt/orderprocessor/.spin
	rm -rf ./apps/mqtt/fulfilmentprocessor/target
	rm -rf ./apps/mqtt/fulfilmentprocessor/.spin
	rm -rf ./apps/redis/fulfilmentprocessor/target
	rm -rf ./apps/redis/fulfilmentprocessor/.spin
	rm -rf ./apps/redis/orderprocessor/target
	rm -rf ./apps/redis/orderprocessor/.spin
	rm -rf ./apps/shared/orderstatusprovider/target
	rm -rf ./apps/shared/orderstatusprovider/.spin
	rm -rf ./tests/target
