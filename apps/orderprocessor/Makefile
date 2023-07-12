all: spin_build k8s_build k8s_push k8s_deploy

spin_build:
	@echo "Building application..."
	spin build
	@echo "Copying target folder from parent workspace to app folder..."
	cp -r ../../target .

k8s_build:
	@echo "Deploying entry app..."
	sh ./deployment/deploy-workload.sh entry $(K3DCLUSTERNAME)

k8s_push:
	spin k8s push

k8s_deploy:
	spin k8s deploy