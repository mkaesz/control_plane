locals {
  hostname_master = "${format("%s-%s-%s", "${var.facilities[0]}", "control-plane", "master")}"
}

// Setup the kubernetes master node

resource "upcloud_server" "master" {
  zone       = "${var.facilities[0]}"
  hostname   = "${local.hostname_master}"

  plan = "${var.master_plan}"

  # Login details 
  login {
    user = "root"

    keys = [
      "${var.public_key}",
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

resource "null_resource" "setup_master" {
  connection {
    user     = "${var.default_user}"
    password = "${var.default_password}"
    host     = "${upcloud_server.master.ipv4_address_private}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-system.sh"
    destination = "/tmp/setup-system.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-kubectl.sh"
    destination = "/tmp/setup-kubectl.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/create-stack.sh"
    destination = "/tmp/create-stack.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.setup_kubeadm.rendered}"
    destination = "/tmp/generate-kubeadm-config.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.authorized_keys.rendered}"
    destination = "/tmp/authorized_keys"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${local.hostname_master}",
      "sudo chmod +x /tmp/*.sh",
      "sudo /tmp/setup-system.sh",
      "sudo /tmp/generate-kubeadm-config.sh",
#      "sudo /tmp/create-stack.sh minimal",
      "/tmp/setup-kubectl.sh",
      "mkdir -p ~/.ssh/ && mv /tmp/authorized_keys ~/.ssh/ && chown clearlinux:clearlinux ~/.ssh/authorized_keys",
      "sudo reboot",
    ]
  }
}

data "external" "kubeadm_join" {
  program = ["./scripts/kubeadm-token.sh"]

  query = {
    host     = "${upcloud_server.master.ipv4_address_private}"
    user     = "${var.default_user}"
    password = "${var.default_password}"
  }

  # Make sure to only run this after the master is up and setup
  depends_on = ["upcloud_server.master"]
}

data "template_file" "setup_kubeadm" {
  template = "${file("${path.module}/templates/generate-kubeadm-config.sh.tpl")}"

  vars = {
    hostname		    = "${local.hostname_master}"
    local_ip		    = "${upcloud_server.master.ipv4_address_private}"
    kubernetes_port         = "${var.kubernetes_port}"
    kubernetes_dns_ip       = "${var.kubernetes_dns_ip}"
    kubernetes_dns_domain   = "${var.kubernetes_dns_domain}"
    kubernetes_cluster_cidr = "${var.kubernetes_cluster_cidr}"
    kubernetes_service_cidr = "${var.kubernetes_service_cidr}"
  }
}
