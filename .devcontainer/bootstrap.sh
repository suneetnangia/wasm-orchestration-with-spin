# Installs latest stable toolchain for Rust and clippy/fmt for this toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

$HOME/.cargo/bin/rustup update stable && $HOME/.cargo/bin/rustup default stable && $HOME/.cargo/bin/rustup component add clippy rustfmt

# Installs wasm32 compiler targets
$HOME/.cargo/bin/rustup target add wasm32-wasi wasm32-unknown-unknown

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Kubectl
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo mkdir "/etc/apt/keyrings"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install Spin
curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
sudo mv spin /usr/local/bin/
spin plugin install -u https://raw.githubusercontent.com/chrismatteson/spin-plugin-k8s/main/k8s.json --yes

# Install AKS wasm extensions
az extension add --name aks-preview
az extension update --name aks-preview

# Install Redis on Local Docker
# docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 redis/redis-stack:latest

# TODO: Move this to workload cluster creation script
# az login
# az feature register --namespace "Microsoft.ContainerService" --name "WasmNodePoolPreview"
# provider_state="unknown"
# while [[ "$provider_state" != "Registered" ]]
# do
#     provider_state=$(az feature show --namespace "Microsoft.ContainerService" --name "WasmNodePoolPreview" --query "properties.state")
#     echo "Provider state: $provider_state"
#     # Todo: exit immediately if provider_state is "Registered"
#     sleep 3
# done
# # Refresh RP registration
# az provider register --namespace Microsoft.ContainerService