provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "tls_private_key" "provisioning_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "packet_ssh_key" "ssh_key_provisioning" {
  name       = "key for terraform provisioning"
  public_key = "${tls_private_key.provisioning_key.public_key_openssh}"
}

variable "private_key" {
  default = "tls_private_key.provisioning_key.private_key_pem"
}

variable "facilities" {
  default = ["ams1"]
}

variable "packet_project" {
 default = "msk"
}

variable "worker_count" {
  default = 0
}

variable "controller_plan" {
  description = "Set the Packet server type for the controller"
  default     = "t1.small.x86"
}

variable "worker_plan" {
  description = "Set the Packet server type for the workers"
  default     = "t1.small.x86"
}

// General template used to install docker on Ubuntu 16.04
data "template_file" "install_docker" {
  template = "${file("${path.module}/templates/install-docker.sh.tpl")}"

  vars = {
    docker_version = "${var.docker_version}"
  }
}

data "template_file" "install_kubernetes" {
  template = "${file("${path.module}/templates/setup-kube.sh.tpl")}"

  vars = {
    kubernetes_version = "${var.kubernetes_version}"
  }
}
