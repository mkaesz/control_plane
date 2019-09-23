provider "upcloud" {
  # You need to set UpCloud credentials in shell environment variable
  # using .bashrc, .zshrc or similar
  # export UPCLOUD_USERNAME="Username for Upcloud API user"
  # export UPCLOUD_PASSWORD="Password for Upcloud API user"
}

resource "upcloud_server" "example" {
  zone     = "de-fra1"
  hostname = "example.msk.pub"

  cpu = "1"
  mem = "1024"

  # Login details
  login {
    user = "root"

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
}

resource "null_resource" "setup_worker" {
  connection {
    user = "clearlinux"
    host = "${upcloud_server.build.ipv4_address}"
    password = "clearlinux"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello world!'",
    ]
  }
}

output "Public_ip" {
  value = upcloud_server.build.ipv4_address
}
