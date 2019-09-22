resource "null_resource" "test-deployment" {
  connection {
    user = "root"
    host = "${packet_device.k8s_controller.access_public_ipv4}"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://gist.githubusercontent.com/matthewpalmer/d1147ed1066e9219e8c346f4e0dd0488/raw/05b8917f31bd76d9d28fc249d0dfc71523787462/apple.yaml",
      "kubectl apply -f https://gist.githubusercontent.com/matthewpalmer/d70ca836c7d7c5da37660923915d9526/raw/242a8261a6acfbc377926d66ffa6e1f995fd251d/banana.yaml",
      "kubectl apply -f https://gist.githubusercontent.com/matthewpalmer/9721cf9b3b719bd8ae3af00648cbb484/raw/d703d7330f4bba33c2588230f505e802275e2af9/ingress.yaml",
    ]
  }

  depends_on = ["null_resource.calico_node_peers"]
}

