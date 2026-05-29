#!/bin/bash

set -e

echo "================================================="
echo " Kubernetes Pre-Requisites Installation Started"
echo "================================================="

sleep 2

# --------------------------------------------
# STEP 1 - Update Packages
# --------------------------------------------

echo "Updating package index..."
sudo apt update -y

# --------------------------------------------
# STEP 2 - Disable Swap
# --------------------------------------------

echo "Disabling swap..."
sudo swapoff -a
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i '/\s\+swap\s\+/s/^/#/' /etc/fstab

# --------------------------------------------
# STEP 3 - Load Kernel Modules
# --------------------------------------------

echo "Configuring kernel modules..."
sudo tee /etc/modules-load.d/k8s.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# --------------------------------------------
# STEP 4 - Configure sysctl
# --------------------------------------------

echo "Configuring sysctl parameters..."
sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# --------------------------------------------
# STEP 5 - Install containerd
# --------------------------------------------

echo "Installing containerd..."
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y containerd.io

# --------------------------------------------
# STEP 6 - Configure containerd
# --------------------------------------------

echo "Configuring containerd..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# --------------------------------------------
# STEP 7 - Install Kubernetes components
# --------------------------------------------

echo "Installing kubeadm, kubelet, kubectl..."
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

# --------------------------------------------
# FINISHED
# --------------------------------------------

echo "================================================="
echo " Kubernetes Pre-Requisites Installation Completed"
echo "================================================="
