provider "upcloud" {
  # You need to set UpCloud credentials in shell environment variable
  # using .bashrc, .zshrc or similar
  # export UPCLOUD_USERNAME="Username for Upcloud API user"
  # export UPCLOUD_PASSWORD="Password for Upcloud API user"
}

resource "upcloud_server" "build" {
  zone     = "de-fra1"
  hostname = "builder.msk.pub"

  cpu = "1"
  mem = "1024"

  # Login details
  login {
    user = "root"

    keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArVZFm7vRuQehYf8Qcx0MhgEWaSiRliee+Rr6YoMESoqOZ3K5+7b94Bs/aMbZeXeHJ1oH0VrLPUk1ZUMr9KufZoqDn3PPmuIUiPvbvBNYABHjkmf44W9WARGJypdYMkSp/1URZ+T8UDtWgGMYt1pmK/rackPBXLgXDNgfDRYuNc+XD19k3UdZ2OSV+l/a29snN4aDi5C+CA/bqys+Zela/CHJcB3BxhQWqZySLbOoMzh1aeFQ49Hj7tHbrxmMgP5p4P8ybN3m/tlzAHB9VhMtS75W0T9dYVdKcBMyS/0gdbFghMvfxpaN6/MW+3zkSS2xZ4KaGgpN8cJEN4X5Ft9FRw==",
    ]

    create_password   = false
    password_delivery = "none"
  }

  storage_devices {
    # You can use both storage template names and UUIDs
    size    = 10
    action  = "clone"
    tier    = "maxiops"
    storage = "Clearlinux"
  }

  storage_devices {
    # You can use both storage template names and UUIDs
    size    = 10
    action  = "create"
    tier    = "maxiops"
  }
}

resource "null_resource" "setup_worker" {
  connection {
    user = "clearlinux"
    host = "${upcloud_server.build.ipv4_address}"
    password = "clearlinux"
  }

  provisioner "file" {
    source      = "${path.module}/kvm-legacy.yaml"
    destination = "/tmp/kvm-legacy.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/*",
      "sudo swupd bundle-add clr-installer",
      "sudo clr-installer -c /tmp/kvm-legacy.yaml",
      "sudo dd if=kvm-legacy.img of=/dev/sdb bs=16M oflag=direct",
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -X POST -H 'Content-Type: application/json' \
             --user "$UPCLOUD_USERNAME:$UPCLOUD_PASSWORD" \
             https://api.upcloud.com/1.3/server/${upcloud_server.build.id}/stop &&
        sleep 75 &&
	curl -X POST \
	     -H 'Content-Type: application/json' \
	     -d '{"storage":{"title":"Clearlinux custom distribution"}}' \
 	     --user "$UPCLOUD_USERNAME:$UPCLOUD_PASSWORD" \
             https://api.upcloud.com/1.3/storage/${upcloud_server.build.storage_devices[1].id}/templatize &&
        sleep 20
EOT
  }
}

output "Public_ip" {
  value = upcloud_server.build.ipv4_address
}
