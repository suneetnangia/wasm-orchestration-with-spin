#! /bin/bash
cd $2/$1

# build the app
spin build
cp -r ../../target .

# get the version from the spin.toml file
VERSION=`grep ^version spin.toml | cut -d'"' -f 2`

# build the docker image
docker buildx build -f Dockerfile -t $1:$VERSION . --load --platform=wasi/wasm32 --provenance=false

# tag the image
docker tag $1:$VERSION $1:latest
# push the image (all-tags option not supported in some daemons versions)
docker image push $1:$VERSION
docker image push $1:$VERSION

cd ../..
