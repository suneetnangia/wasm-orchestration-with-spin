# Development Setup

This document describes the dev setup of the solution.

## Prerequisites

1. Ensure Docker Desktop is installed and setup with ["Use Containerd for pulling and storing images"](https://docs.docker.com/desktop/containerd/) feature.

## Load Dev Environment

Clone the repo on your local machine and open it in VS Code

    ```bash
        git clone https://github.com/suneetnangia/wasm-orchestration-with-spin.git && cd wasm-orchestration-with-spin
        code .
    ```

Repo contains the [devcontainer](../.devcontainer/devcontainer.json) setup that installs all required tools and sdks as below:

- [rust](https://www.rust-lang.org/), rustup and wasm32-wasi target
- [spin](https://www.fermyon.com/spin): framework and dev tool for building WebAssembly (nano) services
- [k3d](https://k3d.io/): lightweight wrapper that runs a k3s cluster in docker
- [kubeclt](https://kubernetes.io/docs/reference/kubectl/): Kubernetes command line tool
- [helm](https://helm.sh/): Kubernetes package manager based on helm charts
- ...

Just start the Dev Container by clicking the double-arrow icon in the bottom left corner of VS Code and select `Reopen in Container` or press `F1` and type `Remote-Containers: Reopen in Container`.

## Deploy K3d Cluster and Workloads

### Initial Setup

Run the `make` command in root of the repo.

This command does the following:

1. Deploys k3d cluster called **wasm-cluster** including Spin's Containerd shim on the nodes.
2. Deploys Redis-Stack as a pod, which contains Redis server and web UI.
3. Deploys workload apps which demonstrate a simple asynchronous order process.
4. Forwards ports to the host machine to allow http endpoints of apps (port 8002) and Redis-Stack UX (port 8001) can be accessed via localhost.

#### Single Spin App Change Loop

Follow these steps to test your changes quickly, when you make iterative changes to Spin apps:

1. Increment the version in the spin.toml in the app folder, e.g. `apps/orderprocessor/spin.toml`
2. Run the `make` command in the app folder, e.g. `apps/orderprocessor`.

We read the version from the spin.toml file, update the deploy.yaml and use this version as new image tag for the Spin app that is going to be imported and deployed into the k3d cluster.

### Test the Sample Workloads (`Make Test` coming soon)

Check the sample solution as follows:

- Post New Order: POST/[http://localhost:8002/order](http://localhost:8002/order)

  ```json
  {
      "details": "Your order"
  }
  ```

  It returns a 202 accepted response with status as _created_, auto generated orderId and the url for the status request endpoint.

- Get Status: GET/[http://localhost:8002/order/\<orderId>](http://localhost:8002/order/<orderId>)
  
  Once the order has been processed by the Fulfilment Processor app (a wasm component in Spin), the status changes to _fulfilled_ and that is returned in the response message.

> you can open the redis-stack dashboard in the browser via [http://localhost:8001](http://localhost:8001) to see how the message is being processed by the apps.
