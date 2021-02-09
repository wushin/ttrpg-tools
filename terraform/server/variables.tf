variable "aws_region" {
  description = "Region services should spawn in"
  type        = string
}
variable "instance_type" {
  description = "What size of ec2 server to run on"
  type        = string
}
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
variable "git_user" {
  description = "Github account"
  type        = string
}
variable "aws_access_key_id" {
  description = "AWS Access Key Id"
  type        = string
}
variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
}
