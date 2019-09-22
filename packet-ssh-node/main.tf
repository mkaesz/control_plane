provider "packet" {
  auth_token = "${var.auth_token}"
}

variable "auth_token" {
 default = "msk"
}

variable "packet_project" {
 default = "msk"
}
