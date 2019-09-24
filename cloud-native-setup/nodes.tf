resource "upcloud_server" "nodes" {
  zone     = "de-fra1"
  hostname = "examplenodes.msk.pub"

  plan = "6xCPU-16GB"

  # Login details
  login {
    user = "root"

    # This key will not be injected. I had to add as the Upcloud Provider wants a key and also validates it. User will be clearlinux with password clearlinux.
    keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArVZFm7vRuQehYf8Qcx0MhgEWaSiRliee+Rr6YoMESoqOZ3K5+7b94Bs/aMbZeXeHJ1oH0VrLPUk1ZUMr9KufZoqDn3PPmuIUiPvbvBNYABHjkmf44W9WARGJypdYMkSp/1URZ+T8UDtWgGMYt1pmK/rackPBXLgXDNgfDRYuNc+XD19k3UdZ2OSV+l/a29snN4aDi5C+CA/bqys+Zela/CHJcB3BxhQWqZySLbOoMzh1aeFQ49Hj7tHbrxmMgP5p4P8ybN3m/tlzAHB9VhMtS75W0T9dYVdKcBMyS/0gdbFghMvfxpaN6/MW+3zkSS2xZ4KaGgpN8cJEN4X5Ft9FRw==",]

    create_password   = false
    password_delivery = "none"
  }

  storage_devices {
    # You can use both storage template names and UUIDs
    size    = "320"
    action  = "clone"
    tier    = "maxiops"
    storage = "Clearlinux custom distribution"
  }
}

resource "null_resource" "setup_worker2" {
  connection {
    user = "clearlinux"
    host = "${upcloud_server.nodes.ipv4_address}"
    password = "clearlinux"
  }

  provisioner "remote-exec" {
    inline = [
      "echo",
    ]
  }
}

output "Public_ip_node" {
  value = upcloud_server.nodes.ipv4_address
}
