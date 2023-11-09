K3DCLUSTERNAME = wasm-cluster
APPSDIR := ./..

k3s_build_deploy:
	@echo "Deploying orderstatusprovider app..."
	sh ../../../deployment/build-deploy-workload.sh orderstatusprovider $(K3DCLUSTERNAME) $(APPSDIR)

clean:
	rm -rf ./target
	rm -rf ./spin
	cargo clean
	kubectl delete -f ./deploy.yaml
	kubectl delete -f ./service.yaml

