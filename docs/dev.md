# Development Setup

This document describes the dev setup of the solution.

## Prerequisites

1. Ensure Docker Desktop is installed and setup with ["Use containerd for pulling and storing images"](https://docs.docker.com/desktop/containerd/) feature.

2. Clone the repo on your local machine and open it in VS Code

    ```bash
        mkdir yourWASMfolder
        git clone https://github.com/suneetnangia/wasm-orchestration-with-spin.git
        code .
    ```

## Load the environment

The folder already contains a devcontainer setup and bootstrap file that installs all required tools and sdks

- [rust](https://www.rust-lang.org/), rustup and wasm32-wasi target
- [k3d](https://k3d.io/) --> lightweight wrapper that runs a k3s cluster in docker
- [kubeclt](https://kubernetes.io/docs/reference/kubectl/) --> Kubernetes command line tool
- [helm](https://helm.sh/) --> Kubernetes package manager based on helm charts
- [spin](https://www.fermyon.com/spin) --> framework and dev tool for building WebAssembly (nano) services

Just start the devcontainer by clicking the double-arrow icon in the bottom left corner of VS Code and select `Reopen in Container` or press `F1` and type `Remote-Containers: Reopen in Container`.

## Install the cluster and workload

### Initial setup

Run the `make` command in the rootfolder to install the k3d cluster called **wasm-cluster** including spin shim runtime, redis-stack and the workload apps which demonstrate a simple asynchronous order process.
Ports are forwarded to the host machine so that the apps (port 8002) and redis-stack (port 8001) can be accessed via localhost.

### Deploy single app

If you changed the code of a single app, you have to increment the version in the spin.toml file in the app folder, e.g. ./apps/orderprocessor/spin.toml. Then run the `make` command the apps folder. That reads the version from the spin.toml file, updates the deploy.yaml and uses the version as new image tag that is going to be imported and deployed into the k3d cluster.

## Run the sample workloads

Run the sample as follows:

- new order: send POST/[http://127.0.0.1:8002/order](http://127.0.0.1:8002/order)

    ```json
    {
        "details": "Your order"  
    }       
    ```

  It returns a 202 accepted response including status _created_, the orderId and the url for the status request.

- get status: send GET/[http://127.0.0.1:8002/order/<orderId>](http://127.0.0.1:8002/order/<orderId>)
  
  Once the order has been processed by the fulfilmentprocessor the status changes to _fulfilled_ that is returned in the response message.

> you can open the redis-stack dashboard in the browser via [http://localhost:8001](http://localhost:8001) to see how the message is being processed by the apps.
