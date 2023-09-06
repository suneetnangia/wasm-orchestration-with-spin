#! /bin/bash
IMAGENAME=$(echo ghcr.io/$3/$1 | tr '[:upper:]' '[:lower:]')
LABEL=$(echo org.opencontainers.image.source=https://github.com/$3/$4 | tr '[:upper:]' '[:lower:]')

cd $2/$1

# build the app
spin build
cp -r ../../target .

# get the version from the spin.toml file
VERSION=`grep ^version spin.toml | cut -d'"' -f 2`

# build the docker image
docker buildx build -f Dockerfile -t $IMAGENAME:$VERSION -l $LABEL --load --platform=wasi/wasm32 --provenance=false .

# tag the docker image
docker tag $IMAGENAME:$VERSION $IMAGENAME:latest

docker push $IMAGENAME:$VERSION
docker push $IMAGENAME:$latest

cd ../..