1. [wasm shim](https://github.com/deislabs/containerd-wasm-shims) makes use of runwasi lib under the hoods
2. Shim is a bridge between K8s and containerd
3. [runwasi](https://github.com/containerd/runwasi) is low level runtime like runc for OCI container, this is however used to start wasm containers.
4. What are runtime classes and [how they relate to containerd shims](https://www.alibabacloud.com/blog/getting-started-with-kubernetes-%7C-understanding-kubernetes-runtimeclass-and-using-multiple-container-runtimes_596341)? 

--runtime=io.containerd.wasmedge.v1 below is mid level runtime shim used by docker containerd, default is runc but it can be wasmshims io.containerd.spin.v1
`docker run --rm --runtime=io.containerd.wasmedge.v1 
--platform=wasi/wasm secondstate/rust-example-hello:latest
Hello WasmEdge!`