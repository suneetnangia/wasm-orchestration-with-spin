#! /bin/bash
DELIMETER="-"
FOLDER=$1

PREFIX=${FOLDER%%$DELIMETER*}
INDEX=${#PREFIX}
 
if [[ INDEX -ne ${#FOLDER} ]];
then
    FOLDER=$(echo ${FOLDER:0:$INDEX})
fi
echo "Folder: $FOLDER"
exit 0
# image name/tag must include the Github organization  to be pushed to the Github Container Registry (GHCR)
IMAGENAME=$(echo ghcr.io/$3/$1 | tr '[:upper:]' '[:lower:]')
# label including the Github organization and repository is required to connect it to the right Github repository
LABEL=$(echo org.opencontainers.image.source=https://github.com/$4 | tr '[:upper:]' '[:lower:]')

cd $2/$FOLDER

# build the app
spin build
cp -r ../../../target .

# get the version from the spin.toml file
VERSION=`grep ^version spin.toml | cut -d'"' -f 2`

# build the docker image
docker buildx build -f Dockerfile -t $IMAGENAME:$VERSION --label $LABEL --load --platform=wasi/wasm32 --provenance=false .

# tag the docker image
docker tag $IMAGENAME:$VERSION $IMAGENAME:latest

docker push $IMAGENAME:$VERSION
docker push $IMAGENAME:latest

cd ../../..
