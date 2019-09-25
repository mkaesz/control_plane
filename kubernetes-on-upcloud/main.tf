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
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArVZFm7vRuQehYf8Qcx0MhgEWaSiRliee+Rr6YoMESoqOZ3K5+7b94Bs/aMbZeXeHJ1oH0VrLPUk1ZUMr9KufZoqDn3PPmuIUiPvbvBNYABHjkmf44W9WARGJypdYMkSp/1URZ+T8UDtWgGMYt1pmK/rackPBXLgXDNgfDRYuNc+XD19k3UdZ2OSV+l/a29snN4aDi5C+CA/bqys+Zela/CHJcB3BxhQWqZySLbOoMzh1aeFQ49Hj7tHbrxmMgP5p4P8ybN3m/tlzAHB9VhMtS75W0T9dYVdKcBMyS/0gdbFghMvfxpaN6/MW+3zkSS2xZ4KaGgpN8cJEN4X5Ft9FRw=="
}

variable "facilities" {
  default = ["de-fra1"]
}

variable "worker_count" {
  default = 1
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

data "template_file" "authorized_keys" {
  template = "${file("${path.module}/templates/authorized_keys.tpl")}"

  vars = {
    public_key                = "${var.public_key}"
  }
}

#resource "upcloud_tag" "kubernetes_tag" {
#  count      = "${var.worker_count}"
#  name        = "kubernetes"
#  description = "A Kubernetes node."
#  servers = [
#    "${upcloud_server.master.id}",
    #"${element(upcloud_server.worker.*.id, count.index)}",
#  ]
#}
