cd ./apps/$1
spin build
cp -r ../../target .
mkdir -p tmp
docker buildx build -f Dockerfile -t $1:latest . --load --platform=wasi/wasm32 --provenance=false
docker save -o tmp/$1.tar $1:latest
k3d image import tmp/$1.tar -c $2
rm -r tmp
spin k8s deploy
cd ../..
