#! /bin/bash
cd $3/$1

# build the app
spin build
cp -r ../../../target .

# get the version from the spin.toml file
VERSION=`grep ^version spin.toml | cut -d'"' -f 2`

# build the docker image
mkdir -p tmp
docker buildx build -f Dockerfile -t $1:$VERSION . --load --platform=wasi/wasm32 --provenance=false
docker save -o tmp/$1.tar $1:$VERSION

# import the image into the k3d cluster
k3d image import tmp/$1.tar -c $2
docker rmi $1:$VERSION
rm -r target
rm -r .spin
rm -r tmp

# replace the image in the deployment file
yq -y -Y --in-place "if .spec.template.spec.containers[]? then  .spec.template.spec.containers[].image=\"$1:$VERSION\" else . end" deploy.yaml
kubectl apply -f deploy.yaml
if test -f "./service.yaml"; then
    kubectl apply -f service.yaml
fi

cd ../../..
