#!/bin/bash
# vim: syntax=sh

echo "[----- Setting up Kubernetes using kubeadm ----]"

cat <<EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "${local_ip}"
  bindPort: ${kubernetes_port}
nodeRegistration:
  name: "${hostname}"
  taints:
  - key: "kubeadmNode"
    value: "master"
    effect: "NoSchedule"
  kubeletExtraArgs:
    cgroup-driver: "systemd"
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
clusterName: kubernetes
apiServer:
  extraArgs:
    secure-port: "${kubernetes_port}"
    bind-address: "${local_ip}"
controllerManager:
  extraArgs:
    bind-address: "${local_ip}"
scheduler:
  extraArgs:
    bind-address: "${local_ip}"
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://${local_ip}:2379"
      advertise-client-urls: "https://${local_ip}:2379"
      listen-peer-urls: "https://${local_ip}:2380"
      initial-advertise-peer-urls: "https://${local_ip}:2380"
      initial-cluster: "${hostname}=https://${local_ip}:2380"
      initial-cluster-state: new
    serverCertSANs:
      - "${hostname}"
    peerCertSANs:
      - "${hostname}"
networking:
  dnsDomain: ${kubernetes_dns_domain}
  podSubnet: ${kubernetes_cluster_cidr}
  serviceSubnet: ${kubernetes_service_cidr}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
clusterDNS:
- ${kubernetes_dns_ip}
clusterDomain: ${kubernetes_dns_domain}
# Allowing for CPU pinning and isolation in case of guaranteed QoS class
cpuManagerPolicy: static
systemReserved:
  cpu: 500m
  memory: 256M
kubeReserved:
  cpu: 500m
  memory: 256M
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: "${local_ip}"
EOF

kubeadm init --config kubeadm-config.yaml

echo "[---- Done setting up kubernetes -----]"
