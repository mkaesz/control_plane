resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "packet_ssh_key" "ssh_key_provisioning" {
  name       = "key for terraform provisioning"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "packet_device" "k8s_workers" {
  project_id       = "${var.packet_project}"
  facilities       = ["ams1"]
  count            = "1"
  plan             = "t1.small.x86"
  operating_system = "ubuntu_16_04"
  hostname         = "${format("%s-%s-%d", "ams1", "worker", count.index)}"
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "worker"]
}

# Using a null_resource so the packet_device doesn't not have to wait to be initially provisioned
resource "null_resource" "setup_worker" {
  count = "1"

  connection {
    user = "root"
    host = "${element(packet_device.k8s_workers.*.access_public_ipv4, count.index)}"
    private_key = "${tls_private_key.example.private_key_pem}"
  }
}
