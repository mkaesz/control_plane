provider "upcloud" {
  # You need to set UpCloud credentials in shell environment variable
  # using .bashrc, .zshrc or similar
  # export UPCLOUD_USERNAME="Username for Upcloud API user"
  # export UPCLOUD_PASSWORD="Password for Upcloud API user"
}

resource "tls_private_key" "build" {
  algorithm = "RSA"
  rsa_bits  = 4096
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
      "${tls_private_key.build.public_key_openssh}",
    ]

    create_password   = false
    password_delivery = "none"
  }

  storage_devices {
    # You can use both storage template names and UUIDs
    size    = 10
    action  = "clone"
    tier    = "maxiops"
    storage = "01000000-0000-4000-8000-000050010300"
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
    user = "root"
    host = "${upcloud_server.build.ipv4_address}"
    private_key = "${tls_private_key.build.private_key_pem}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-clearlinux-on-disc.sh"
    destination = "/tmp/setup-clearlinux-on-disc.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/make-basic-setup.sh"
    destination = "/tmp/make-basic-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-clearlinux-on-disc.sh",
      "/tmp/make-basic-setup.sh",
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
	     -d '{"storage":{"title":"Clearlinux"}}' \
 	     --user "$UPCLOUD_USERNAME:$UPCLOUD_PASSWORD" \
             https://api.upcloud.com/1.3/storage/${upcloud_server.build.storage_devices[1].id}/templatize &&
        sleep 20
EOT
  }
}

output "Public_ip" {
  value = upcloud_server.build.ipv4_address
}

output "Private_key" {
  value = tls_private_key.build.private_key_pem
}
