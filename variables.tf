variable "sshpath" {
  description = "Path to a directory where the public and private SSH key will be stored."
  type        = string
}
variable "private_key_name" {
  description = "SSH Private Key filename you want to use"
  type        = string
}
variable "public_key_name" {
  description = "SSH Public Key filename you want to use"
  type        = string
}
variable "ssh_key_algorithm" {
  default     = "RSA"
}
