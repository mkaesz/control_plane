resource "null_resource" "setup_nginx_ingress" {
  connection {
    user = "root"
    host = "${packet_device.k8s_controller.access_public_ipv4}"
    private_key = "${tls_private_key.provisioning_key.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml",
      "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml",
    ]
  }

  depends_on = ["null_resource.calico_node_peers"]
}

