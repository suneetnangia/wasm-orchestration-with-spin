#! /bin/bash
cd $2/$1

# get the version from the spin.toml file
VERSION=`grep ^version spin.toml | cut -d'"' -f 2`

# build the docker image
mkdir -p ../../artifacts
docker save -o ../../artifacts/$1.tar $1:$VERSION

cd ../..
