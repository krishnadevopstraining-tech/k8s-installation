# k8s-installation

This repository contains a Kubernetes pre-requisites installation script for Ubuntu 22.04.

## Files

- `k8s-prereqs.sh` - Installs and configures dependencies required by Kubernetes on all nodes.

## Usage

1. Give execute permission:

```bash
chmod +x k8s-prereqs.sh
```

2. Run the script on every node (master and workers):

```bash
./k8s-prereqs.sh
```

3. On the master node, initialize the cluster:

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

4. Configure kubectl:

```bash
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
```

5. Install Calico:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
```

6. Generate the join command on the master:

```bash
kubeadm token create --print-join-command
```

7. Run the printed join command on each worker node.
