variable "AWS_REGION" {
  default = "ap-south-1"
}
variable "key_name" {}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
