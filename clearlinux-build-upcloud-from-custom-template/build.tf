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
    action  = "clone"
    tier    = "maxiops"
    storage = "0137931a-7aa7-4142-9efe-6d565f661e83"
  }

  storage_devices {
    # You can use both storage template names and UUIDs
    size    = 10
    action  = "create"
    tier    = "maxiops"
  }
}

data "template_file" "setup_node" {
  template = "${file("${path.module}/templates/cloud-init.tpl")}"
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

  provisioner "file" {
    content     = "${data.template_file.setup_node.rendered}"
    destination = "/tmp/cloud-init"
  }

  provisioner "file" {
    source      = "${path.module}/bin/ucd"
    destination = "/usr/bin/ucd"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "chmod +x /usr/bin/ucd",
      "/tmp/setup.sh",
      "/usr/bin/ucd -u /tmp/cloud-init",
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
	     -d '{"storage":{"title":"terraform"}}' \
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
