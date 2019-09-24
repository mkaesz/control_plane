locals {
  hostname = "${format("%s-%s-%s", "${var.facilities[0]}", "control-plane", "master")}"
}

// Setup the kubernetes master node

resource "upcloud_server" "master" {
  zone       = "${var.facilities[0]}"
  hostname   = "${local.hostname}"

  plan = "${var.master_plan}"

  # Login details 
  login {
    user = "root"

    keys = [
      "${tls_private_key.provisioning_key.public_key_openssh}",
    ]

    create_password   = false
    password_delivery = "none"
  }

  storage_devices {
    # You can use both storage template names and UUIDs
    size    = 10
    action  = "clone"
    tier    = "maxiops"
    storage = "Clearlinux custom distribution"
  }

#  storage_devices {
#    # You can use both storage template names and UUIDs
#    size    = 10
 #   action  = "create"
  #  tier    = "maxiops"
 # }
}

resource "null_resource" "setup_node" {
  connection {
    user     = "${var.default_user}"
    password = "${var.default_password}"
    host     = "${upcloud_server.master.ipv4_address}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-system.sh"
    destination = "/tmp/setup-system.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp/"
  }

  provisioner "file" {
    content     = "${data.template_file.setup_kubeadm.rendered}"
    destination = "/tmp/generate-kubeadm-config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${local.hostname}",
      "sudo chmod +x /tmp/*.sh",
      "sudo /tmp/setup-system.sh",
      "sudo /tmp/generate-kubeadm-config.sh",
      "sudo /tmp/create-stack.sh minimal",
      "/tmp/setup-kubectl.sh",
    ]
  }
}

data "external" "kubeadm_join" {
  program = ["./scripts/kubeadm-token.sh"]

  query = {
    host = "${upcloud_server.master.ipv4_address}"
  }

  # Make sure to only run this after the master is up and setup
  depends_on = ["upcloud_server.master"]
}

data "template_file" "setup_kubeadm" {
  template = "${file("${path.module}/templates/generate-kubeadm-config.sh.tpl")}"

  vars = {
    hostname		    = "${local.hostname}"
    local_ip		    = "${upcloud_server.master.ipv4_address_private}"
    kubernetes_port         = "${var.kubernetes_port}"
    kubernetes_dns_ip       = "${var.kubernetes_dns_ip}"
    kubernetes_dns_domain   = "${var.kubernetes_dns_domain}"
    kubernetes_cluster_cidr = "${var.kubernetes_cluster_cidr}"
    kubernetes_service_cidr = "${var.kubernetes_service_cidr}"
  }
}
