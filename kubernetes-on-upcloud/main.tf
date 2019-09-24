provider "upcloud" {
  # You need to set UpCloud credentials in shell environment variable
  # using .bashrc, .zshrc or similar
  # export UPCLOUD_USERNAME="Username for Upcloud API user"
  # export UPCLOUD_PASSWORD="Password for Upcloud API user"
}

resource "tls_private_key" "provisioning_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "private_key" {
  default = "tls_private_key.provisioning_key.private_key_pem"
}

variable "public_key" {
  default = "tls_private_key.provisioning_key.public_key_openssh"
}

variable "facilities" {
  default = ["de-fra1"]
}

variable "worker_count" {
  default = 0
}

variable "kubernetes_port" {
  default = "6443"
}

variable "kubernetes_dns_ip" {
  default = "192.168.0.10"
}

variable "kubernetes_cluster_cidr" {
  default = "172.16.0.0/12"
}

variable "kubernetes_service_cidr" {
  default = "192.168.0.0/16"
}

variable "kubernetes_dns_domain" {
  default = "cluster.local"
}

variable "master_plan" {
  description = "Set the Upcloud server type for the masters"
  default     = "4xCPU-8GB"
}

variable "worker_plan" {
  description = "Set the Upcloud server type for the workers"
  default     = "4xCPU-8GB"
}

variable "default_user" {
  default     = "clearlinux"
}

variable "default_password" {
  default     = "clearlinux"
}
