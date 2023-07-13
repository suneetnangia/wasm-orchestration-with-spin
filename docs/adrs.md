# Architecture Decision Records

This document list the reasoning for various decisions made in the repo.

## Azure Kubernetes Service (AKS)

AKS is Azure's managed K8s service, which allows creating a node pool with Wasm based [containerd shims](https://github.com/deislabs/containerd-wasm-shims).
It was preferred approach initially but we soon realised that it does come with the Spin shim which has a Redis trigger. Additionally, we want to simulate edge environment as closely as possible, use of K3d without any cloud management helps with this requirement, so K3ds get preference here.
Eventually, we may roll out the solution on AKS with a forked (subtree'd) Spin shim.
