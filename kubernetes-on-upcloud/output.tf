output "public_ip_master" {
  value = upcloud_server.master.ipv4_address
}

output "private_ip_master" {
  value = upcloud_server.master.ipv4_address_private
}

output "Private_ip_worker" {
  value = upcloud_server.worker.*.ipv4_address_private
}

output "worker" {
  value = upcloud_server.worker.*
}

output "master" {
  value = upcloud_server.master.*
}

output "private_key" {
  value = "${tls_private_key.provisioning_key.private_key_pem}"
}
