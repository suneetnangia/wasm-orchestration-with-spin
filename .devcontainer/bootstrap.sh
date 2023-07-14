# Installs latest stable toolchain for Rust and clippy/fmt for this toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
PATHRUSTUP=$HOME/.cargo/bin
$PATHRUSTUP/rustup update stable && $PATHRUSTUP/rustup default stable && $PATHRUSTUP/rustup component add clippy rustfmt

# Installs wasm32 compiler targets
$PATHRUSTUP/rustup target add wasm32-wasi wasm32-unknown-unknown

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install Kubectl
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo mkdir "/etc/apt/keyrings"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Spin
curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
sudo mv spin /usr/local/bin/
spin plugin install -u https://raw.githubusercontent.com/chrismatteson/spin-plugin-k8s/main/k8s.json --yes
