spin_build:
	@echo "Building application..."
	spin build

k8s_build:
	@echo "Copying target folder from parent workspace to app folder..."
	cp -r ../../target .
	spin k8s build

k8s_push:
	@echo "Copying target folder from parent workspace to app folder..."
	cp -r ../../target .
	spin k8s push

k8s_deploy:
	@echo "Copying target folder from parent workspace to app folder..."
	cp -r ../../target .
	spin k8s deploy