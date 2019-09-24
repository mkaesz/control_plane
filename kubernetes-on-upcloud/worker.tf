locals {
  hostname_worker = "${format("%s-%s-%s", "${var.facilities[0]}", "control-plane", "worker")}"
}

// Setup the kubernetes worker node

resource "upcloud_server" "worker" {
  count      = "${var.worker_count}"
  zone       = "${var.facilities[0]}"
  hostname   = "${format("%s-%d", "${local.hostname_worker}", count.index)}"

  plan = "${var.worker_plan}"
 # ipv4 = false
  ipv6 = false

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

resource "null_resource" "setup_worker" {
  count = "${var.worker_count}"

  connection {
    user     = "${var.default_user}"
    password = "${var.default_password}"
    host     = "${element(upcloud_server.worker.*.ipv4_address_private, count.index)}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-system.sh"
    destination = "/tmp/setup-system.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${format("%s-%d", "${local.hostname_worker}", count.index)}",
      "sudo chmod +x /tmp/*.sh",
      "sudo /tmp/setup-system.sh",
      "sudo ${data.external.kubeadm_join.result.command}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get nodes -o wide",
    ]

    on_failure = "continue"

    connection {
      user     = "${var.default_user}"
      password = "${var.default_password}"
      host     = "${upcloud_server.master.ipv4_address_private}"
    }
  }
}
