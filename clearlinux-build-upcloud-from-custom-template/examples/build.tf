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

  cpu = "2"
  mem = "2048"

  # Login details
  login {
    user = "root"

    keys = [
      "${tls_private_key.build.public_key_openssh}",
    ]

    create_password   = true
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
    source      = "${path.module}/scripts/prepare_custom_template_based_on_default_kvm_legacy_image.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup.sh",
    ]
  }
}

output "Public_ip" {
  value = upcloud_server.build.ipv4_address
}

output "Private_key" {
  value = tls_private_key.build.private_key_pem
}
